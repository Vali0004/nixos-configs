{ config
, lib
, ... }:

let
  pgSock = "postgresql://sogo@%2Frun%2Fpostgresql/sogo";
in {
  services.nginx.virtualHosts.${config.services.sogo.vhostName} = {
    forceSSL = true;
    enableACME = true;
  };

  services.sogo = {
    enable = true;
    configReplaces = {
      DO_NOT_REPLY_FUCKK_LOL = config.age.secrets.do-not-reply-kursu-dev.path;
    };
    extraConfig = ''
      WOWorkersCount = 4;
      SOGoUserSources = (
        {
          canAuthenticate = YES;
          id = users;
          type = sql;
          userPasswordAlgorithm = crypt;
          viewURL = "${pgSock}/sogo_users";
          LoginFieldNames = ("c_name", "mail");
          MailFieldNames = ("mail");
        }
      );

      SOGoCacheCleanupInterval = 300;
      SOGoMemcachedHost = "192.168.100.1";

      SOGoMailDomain = "${config.services.sogo.vhostName}";
      SOGoEnableEMailAlarms = YES;
      SOGoMailCustomFromEnabled = YES;
      SOGoMailingMechanism = "smtp";

      SOGoIMAPServer = "imaps://mail.kursu.dev/?tls=YES&tlsVerifyMode=default";
      // When logging in to the SMTP server, the primary email address of the user will be used instead of the username.
      SOGoForceExternalLoginWithEmail = YES;
      NGImap4DisableIMAP4Pooling = YES;
      NGImap4AuthMechanism = "plain";

      SOGoSMTPServer = "smtp://mail.kursu.dev:587/?tls=YES&tlsVerifyMode=default";
      SOGoSMTPAuthenticationType = "PLAIN";
      SOGoSMTPMasterUserEnabled = YES;
      SOGoSMTPMasterUserUsername = "do-not-reply@kursu.dev";
      SOGoSMTPMasterUserPassword = DO_NOT_REPLY_FUCKK_LOL;

      SOGoMailKeepDraftsAfterSend = YES;

      SOGoProfileURL = "${pgSock}/sogo_user_profile";
      OCSFolderInfoURL = "${pgSock}/sogo_folder_info";
      OCSSessionsFolderURL = "${pgSock}/sogo_sessions_folder";
      OCSEMailAlarmsFolderURL = "${pgSock}/sogo_alarms_folder";
      OCSStoreURL = "${pgSock}/sogo_store";
      OCSAclURL = "${pgSock}/sogo_acl";
      OCSCacheFolderURL = "${pgSock}/sogo_cache_folder";
      OCSAdminURL = "${pgSock}/sogo_admin";

      SOGoDebugRequests = YES;
      SOGoEASDebugEnabled = YES;
      SOGoImapDebugEnabled = YES;
      NGImap4DebugEnabled = YES;
    '';
    timezone = "America/Detroit";
    vhostName = "mail.kursu.dev";
  };

  systemd.services = {
    sogo.serviceConfig = lib.mkNamespace {};
    sogo-tmpwatch.serviceConfig = lib.mkNamespace {};
    sogo-ealarms.serviceConfig = lib.mkNamespace {};
  };
}