{ pkgs ? import <nixpkgs> {} }:
let
  yaml2json = pkgs.buildGoModule {
    name = "k8syaml2json";
    src = pkgs.fetchgit {
      url = "https://github.com/euank/k8syaml2json.git";
      rev = "e5155f75cd228dc7b3cb40a5f6f7c4ac9fd24d03";
      sha256 = "0gpxwczyr9kblsvvjwa73pnckim3zz39nkwh3h4bnn5wdaf4l1x1";
    };
    vendorSha256 = "0fnwhpzf2ps11r11x677g34hrxpmw22iqgrq611wn9msvwazrbmg";
  };
  lib = pkgs.lib;
in
  {
    # Convert a valid k8s yaml file to a set of kubernetes resources suitable for kubenix
    yaml2Resources = yaml:
      let
        # Convert the yaml file into N json files
        jsonFiles = pkgs.runCommand "convert-k8s-yaml" {} ''
          mkdir $out && cd $out
          ${yaml2json}/bin/k8syaml2json < ${yaml} | ${pkgs.gawk}/bin/awk '{print > NR}'
        '';
        # Get the list of json files
        filesAttr = builtins.readDir "${jsonFiles}";
        # Read them
        jsonStrings = builtins.map (p: builtins.readFile "${jsonFiles}/${p}") (lib.attrNames filesAttr);
        # Convert them to nix expressions
        nixExprs = builtins.map builtins.fromJSON jsonStrings;
        mergeAttrs = lib.fold (lhs: rhs: lhs // rhs) {};
        convertExpr = expr:
          let
            # Pull out k8s metadata
            apiVersion = expr.apiVersion;
            apiVersionParts = lib.splitString "/" apiVersion;
            groupVersion =
              if lib.length apiVersionParts == 0 then throw "apiVersion must be of the form 'ResourceVersion' or 'group/ResourceVersoin', was empty"
              else if lib.length apiVersionParts == 1 then { group = "core"; version = lib.head apiVersionParts; }
              else if lib.length apiVersionParts == 2 then { group = lib.head apiVersionParts; version = lib.elemAt apiVersionParts 1; }
              else throw "apiVersion must have only one slash in it, was ${apiVersion}";
            kind = expr.kind;
            name = expr.metadata.name;
            filterMetadata = expr:
              let
                filterPaths = ["apiVersion" "kind"];
                filterName = expr: expr // { metadata = lib.filterAttrs (n: _: n != "name") expr.metadata; };
              in
                lib.filterAttrs (n: _: !(builtins.elem n filterPaths)) (filterName expr);
        in
          {
            "${groupVersion.group}"."${groupVersion.version}"."${kind}"."${name}" = filterMetadata expr;
          };
        in
          mergeAttrs (builtins.map convertExpr nixExprs);
  }
