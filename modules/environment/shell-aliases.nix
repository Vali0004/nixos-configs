{
  environment.shellAliases = {
    l = null;
    ll = null;
    lss = "ls --color -lha";
    agenix = "agenix -i /home/vali/.ssh/nixos_main";
    git-update = "git stash push && git pull && git stash pop && git add .";
  };
}