{
  pkgs ? import <nixpkgs> {},
  kubenix ? import (pkgs.fetchgit {
    url = "https://github.com/xtruder/kubenix/";
    rev = "611059a329493a77ec0e862fcce4671cd3768f32";
    sha256 = "1lmmzb087ahmx2mdjarbi52a9424qczhzqbxrvcrg11cbmv9b191";
  }) {}
}:

let
  secrets = if builtins.pathExists ./secrets.nix then import ./secrets.nix else import ./secrets.example.nix;
  kpkgs = import ./kpkgs { inherit pkgs; };
  configuration = {config, ...}: {
    imports = [
      kubenix.modules.k8s
      ./kubenix/modules/euircbot
    ];

    euircbot = {
      enable = true;
      config = {
        nick = "^";
        server = "irc.wobscale.website";
        owner = "ek";
        ssl = true;
        port = 6697;
        mainChannel = secrets.euircbot.mainChannel;
      };
      # TODO: obviously
      dataVolume = {
        hostPath = { path = "/var/lib/k8s/euircbot"; };
      };
      moduleConfig = secrets.euircbot.modules // {
        "dumbcommand.json" = {
          allow_commands = false;
        };
      };
    };
  };

  eval = (kubenix.evalModules {
    specialArgs = {
      inherit kubenix pkgs kpkgs;
    };
    modules = [ configuration ];
  });
in
  eval.config.kubernetes.result
