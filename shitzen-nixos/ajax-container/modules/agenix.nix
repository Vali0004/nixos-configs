{ ... }:

{
  age.secrets = {
    oauth2 = {
      file = ../../../secrets/oauth2.age;
      owner = "nginx";
      group = "nginx";
    };
    oauth2-proxy = {
      file = ../../../secrets/oauth2-proxy.age;
      owner = "nginx";
      group = "nginx";
    };
  };
}
