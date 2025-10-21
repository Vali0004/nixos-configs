{ ... }:

{
  environment.shellAliases = {
    l = null;
    ll = null;
    lss = "ls --color -lha";
    git-update = "git stash push && git pull && git stash pop && git add .";
  };
}