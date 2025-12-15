{ config
, lib
, ... }:

let
  dbUrl = "postgresql://sogo:sogo@192.168.100.1:5432/sogo/sogo_users";
in {
  services.nginx.virtualHosts.${config.services.sogo.vhostName} = {
    forceSSL = true;
    enableACME = true;
  };

  services.sogo = {
    enable = true;
    configReplaces = {
      DO_NOT_REPLY_FUCKK_LOL = config.age.secrets.do-not-reply-fuckk-lol.path;
    };
    extraConfig = ''
      WOWorkersCount = 4;
      SOGoUserSources = (
        {
          canAuthenticate = YES;
          id = users;
          type = sql;
          userPasswordAlgorithm = crypt;
          viewURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_users";
        }
      );

      SOGoCacheCleanupInterval = 300;
      SOGoMemcachedHost = "192.168.100.1";

      SOGoMailDomain = "fuckk.lol";
      SOGoEnableEMailAlarms = YES;
      SOGoMailCustomFromEnabled = YES;
      SOGoMailingMechanism = "mail";

      SOGoIMAPServer = "imaps://mail.fuckk.lol/?tls=YES&tlsVerifyMode=default";
      // When logging in to the SMTP server, the primary email address of the user will be used instead of the username.
      SOGoForceExternalLoginWithEmail = YES;
      NGImap4DisableIMAP4Pooling = YES;
      NGImap4AuthMechanism = "plain";

      SOGoSMTPServer = "smtp://mail.fuckk.lol:587/?tls=YES&tlsVerifyMode=default";
      SOGoSMTPAuthenticationType = "PLAIN";
      SOGoSMTPMasterUserEnabled = YES;
      SOGoSMTPMasterUserUsername = "do-not-reply@fuckk.lol";
      SOGoSMTPMasterUserPassword = DO_NOT_REPLY_FUCKK_LOL;

      SOGoMailKeepDraftsAfterSend = YES;

      SOGoProfileURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_user_profile";
      OCSFolderInfoURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_folder_info";
      OCSSessionsFolderURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_sessions_folder";
      OCSEMailAlarmsFolderURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_alarms_folder";
      OCSStoreURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_store";
      OCSAclURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_acl";
      OCSCacheFolderURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_cache_folder";
      OCSAdminURL = "postgresql://sogo@%2Frun%2Fpostgresql:5432/sogo/sogo_admin";
    '';
    timezone = "America/Detroit";
    vhostName = "mail.fuckk.lol";
  };

  systemd.services = {
    sogo.serviceConfig = lib.mkNamespace {};
    sogo-tmpwatch.serviceConfig = lib.mkNamespace {};
    sogo-ealarms.serviceConfig = lib.mkNamespace {};
  };
}