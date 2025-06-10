{ mkDerivation, alex-tools, base, binary, bytestring, containers
, file-embed, filepath, hashable, language-lua, lib, megaparsec
, mtl, optparse-applicative, parser-combinators, template-haskell
, text
}:
mkDerivation {
  pname = "lua2jass";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    alex-tools base binary bytestring containers file-embed filepath
    hashable language-lua megaparsec mtl optparse-applicative
    parser-combinators template-haskell text
  ];
  license = lib.licenses.agpl3Only;
  mainProgram = "lua2jass";
}
