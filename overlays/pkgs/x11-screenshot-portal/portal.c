#define _DEFAULT_SOURCE
#include <fcntl.h>
#include <gio/gio.h>
#include <glib/gstdio.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define BUS_NAME "org.freedesktop.impl.portal.desktop.x11_screenshot"
#define OBJECT_PATH "/org/freedesktop/portal/desktop"
#define SCREENSHOT_INTERFACE "org.freedesktop.impl.portal.Screenshot"
#define REQUEST_INTERFACE "org.freedesktop.impl.portal.Request"
#define FILE_LIFETIME_SECONDS (24 * 60 * 60)

/* Read the backend XML installed by the pinned xdg-desktop-portal package. */
static const char screenshot_xml_path[] = "@portal-xml@";
static const char request_xml[] =
    "<node><interface name='" REQUEST_INTERFACE "'>"
    "<method name='Close'/></interface></node>";

typedef struct {
    GDBusConnection *connection;
    GDBusMethodInvocation *invocation;
    GSubprocess *process;
    char *filename;
    guint registration;
    gboolean finished;
    gboolean keep_file;
} Request;

static GDBusNodeInfo *screenshot_node;
static GDBusNodeInfo *request_node;

static GVariant *
empty_response(guint response)
{
    return g_variant_new("(u@a{sv})", response,
        g_variant_new_array(G_VARIANT_TYPE("{sv}"), NULL, 0));
}

static char *
screenshot_directory(void)
{
    return g_build_filename(g_get_user_runtime_dir(), "x11-screenshot-portal", NULL);
}

static gboolean
cleanup_old_files(void *unused)
{
    (void)unused;
    g_autofree char *directory = screenshot_directory();
    g_autoptr(GDir) dir = g_dir_open(directory, 0, NULL);
    if (!dir)
        return G_SOURCE_CONTINUE;

    const char *name;
    time_t now = time(NULL);
    while ((name = g_dir_read_name(dir))) {
        if (!g_str_has_prefix(name, "screenshot-"))
            continue;
        g_autofree char *path = g_build_filename(directory, name, NULL);
        struct stat info;
        if (g_lstat(path, &info) == 0 && S_ISREG(info.st_mode) &&
            now - info.st_mtime > FILE_LIFETIME_SECONDS)
            g_unlink(path);
    }
    return G_SOURCE_CONTINUE;
}

static void
request_free(Request *request)
{
    if (request->filename && !request->keep_file)
        g_unlink(request->filename);
    g_clear_object(&request->process);
    g_clear_object(&request->invocation);
    g_clear_object(&request->connection);
    g_free(request->filename);
    g_free(request);
}

static void
request_finish(Request *request, guint response, const char *uri)
{
    if (request->finished)
        return;
    request->finished = TRUE;
    if (request->registration)
        g_dbus_connection_unregister_object(request->connection, request->registration);
    GVariantBuilder results;
    g_variant_builder_init(&results, G_VARIANT_TYPE_VARDICT);
    if (response == 0 && uri) {
        request->keep_file = TRUE;
        g_variant_builder_add(&results, "{sv}", "uri", g_variant_new_string(uri));
    }
    g_dbus_method_invocation_return_value(request->invocation,
        g_variant_new("(ua{sv})", response, &results));
}

static void
capture_done(GObject *source, GAsyncResult *result, void *user_data)
{
    Request *request = user_data;
    g_autoptr(GError) error = NULL;
    gboolean waited = g_subprocess_wait_finish(G_SUBPROCESS(source), result, &error);
    if (!request->finished) {
        if (waited && g_subprocess_get_successful(G_SUBPROCESS(source))) {
            g_autofree char *uri = g_filename_to_uri(request->filename, NULL, NULL);
            request_finish(request, uri ? 0 : 2, uri);
        } else {
            request_finish(request, 2, NULL);
        }
    }
    request_free(request);
}

static void
start_capture(Request *request)
{
    g_autofree char *directory = screenshot_directory();
    if (g_mkdir_with_parents(directory, 0700) != 0) {
        request_finish(request, 2, NULL);
        request_free(request);
        return;
    }

    request->filename = g_build_filename(directory, "screenshot-XXXXXX", NULL);
    int fd = g_mkstemp_full(request->filename, O_RDWR, 0600);
    if (fd < 0) {
        request_finish(request, 2, NULL);
        request_free(request);
        return;
    }
    close(fd);

    const char *argv[] = { "maim", "-f", "png", request->filename, NULL };
    g_autoptr(GError) error = NULL;
    g_clear_object(&request->process);
    request->process = g_subprocess_newv(argv, G_SUBPROCESS_FLAGS_NONE, &error);
    if (!request->process) {
        request_finish(request, 2, NULL);
        request_free(request);
        return;
    }
    g_subprocess_wait_async(request->process, NULL, capture_done, request);
}

static void
consent_done(GObject *source, GAsyncResult *result, void *user_data)
{
    Request *request = user_data;
    g_autoptr(GError) error = NULL;
    g_autofree char *answer = NULL;
    gboolean replied = g_subprocess_communicate_utf8_finish(
        G_SUBPROCESS(source), result, &answer, NULL, &error);
    if (request->finished) {
        request_free(request);
        return;
    }
    if (!replied || !g_subprocess_get_successful(G_SUBPROCESS(source)) ||
        !answer || g_strcmp0(g_strstrip(answer), "Allow") != 0) {
        request_finish(request, 1, NULL);
        request_free(request);
        return;
    }
    start_capture(request);
}

static void
request_method_call(GDBusConnection *connection, const char *sender,
                    const char *path, const char *interface, const char *method,
                    GVariant *parameters, GDBusMethodInvocation *invocation,
                    void *user_data)
{
    (void)connection; (void)sender; (void)path; (void)interface;
    (void)parameters;
    Request *request = user_data;
    if (g_strcmp0(method, "Close") != 0) {
        g_dbus_method_invocation_return_error_literal(invocation, G_DBUS_ERROR,
            G_DBUS_ERROR_UNKNOWN_METHOD, "Unknown request method");
        return;
    }
    g_dbus_method_invocation_return_value(invocation, g_variant_new("()"));
    if (request->process)
        g_subprocess_force_exit(request->process);
    request_finish(request, 1, NULL);
    /* The outstanding consent or capture callback owns the final reference.
     * Both callbacks check finished before touching any request state. */
}

static const GDBusInterfaceVTable request_vtable = {
    .method_call = request_method_call,
};

static void
screenshot_method_call(GDBusConnection *connection, const char *sender,
                       const char *path, const char *interface, const char *method,
                       GVariant *parameters, GDBusMethodInvocation *invocation,
                       void *user_data)
{
    (void)sender; (void)path; (void)interface; (void)user_data;
    if (g_strcmp0(method, "PickColor") == 0) {
        /* This backend only implements screenshots; color picking is unsupported. */
        g_dbus_method_invocation_return_value(invocation,
            empty_response(2));
        return;
    }

    const char *handle, *app_id, *parent_window;
    g_autoptr(GVariant) options = NULL;
    g_variant_get(parameters, "(&o&s&s@a{sv})", &handle, &app_id,
                  &parent_window, &options);
    (void)parent_window;
    guint target = 1;
    if (g_variant_lookup(options, "target", "u", &target) && target != 1) {
        g_dbus_method_invocation_return_value(invocation,
            empty_response(2));
        return;
    }

    Request *request = g_new0(Request, 1);
    request->connection = g_object_ref(connection);
    request->invocation = g_object_ref(invocation);
    g_autoptr(GError) error = NULL;
    request->registration = g_dbus_connection_register_object(connection, handle,
        request_node->interfaces[0], &request_vtable, request, NULL, &error);
    if (!request->registration) {
        g_dbus_method_invocation_return_gerror(invocation, error);
        request_free(request);
        return;
    }

    /* app_id is display text only. The choice is the authorization decision. */
    g_autofree char *prompt = g_strdup_printf("Allow %s to capture the screen?",
        *app_id ? app_id : "an unidentified application");
    const char *argv[] = { "rofi", "-dmenu", "-p", prompt, NULL };
    request->process = g_subprocess_newv(argv,
        G_SUBPROCESS_FLAGS_STDIN_PIPE | G_SUBPROCESS_FLAGS_STDOUT_PIPE, &error);
    if (!request->process) {
        request_finish(request, 2, NULL);
        request_free(request);
        return;
    }
    g_subprocess_communicate_utf8_async(request->process, "Allow\nDeny\n",
                                        NULL, consent_done, request);
}

static GVariant *
get_property(GDBusConnection *connection, const char *sender, const char *path,
             const char *interface, const char *property, GError **error,
             void *user_data)
{
    (void)connection; (void)sender; (void)path; (void)interface; (void)user_data;
    if (g_strcmp0(property, "version") == 0)
        return g_variant_new_uint32(3);
    if (g_strcmp0(property, "AvailableTargets") == 0)
        return g_variant_new_uint32(1); /* Screen is bit 0 in the installed XML. */
    g_set_error(error, G_DBUS_ERROR, G_DBUS_ERROR_UNKNOWN_PROPERTY,
                "Unknown property: %s", property);
    return NULL;
}

static const GDBusInterfaceVTable screenshot_vtable = {
    .method_call = screenshot_method_call,
    .get_property = get_property,
};

static void
bus_acquired(GDBusConnection *connection, const char *name, void *user_data)
{
    (void)name; (void)user_data;
    g_autoptr(GError) error = NULL;
    if (!g_dbus_connection_register_object(connection, OBJECT_PATH,
            screenshot_node->interfaces[0], &screenshot_vtable, NULL, NULL, &error))
        g_error("Failed to register Screenshot interface: %s", error->message);
}

int
main(void)
{
    g_autoptr(GError) error = NULL;
    g_autofree char *xml = NULL;
    if (!g_file_get_contents(screenshot_xml_path, &xml, NULL, &error))
        g_error("Failed to read installed Screenshot XML: %s", error->message);
    screenshot_node = g_dbus_node_info_new_for_xml(xml, &error);
    if (!screenshot_node)
        g_error("Failed to parse installed Screenshot XML: %s", error->message);
    request_node = g_dbus_node_info_new_for_xml(request_xml, &error);
    if (!request_node)
        g_error("Failed to parse Request XML: %s", error->message);

    cleanup_old_files(NULL);
    g_timeout_add_seconds(60 * 60, cleanup_old_files, NULL);
    g_autoptr(GMainLoop) loop = g_main_loop_new(NULL, FALSE);
    guint owner = g_bus_own_name(G_BUS_TYPE_SESSION, BUS_NAME,
        G_BUS_NAME_OWNER_FLAGS_NONE, bus_acquired, NULL, NULL, NULL, NULL);
    g_main_loop_run(loop);
    g_bus_unown_name(owner);
    g_dbus_node_info_unref(request_node);
    g_dbus_node_info_unref(screenshot_node);
    return 0;
}
