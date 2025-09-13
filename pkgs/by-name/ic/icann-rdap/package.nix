{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "icann-rdap";
  version = "0.0.23";

  src = fetchFromGitHub {
    owner = "icann";
    repo = "icann-rdap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1e8r8JkRUokleQnDzxYLClC82R4HXlctNXxfSN3DicY=";
  };

  cargoHash = "sha256-4PFLQeLMcUYEK2v0dR0EmHUcqtRqZ3UamFVOzUNAPwE=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  env.OPENSSL_NO_VENDOR = true;

  # https://github.com/icann/icann-rdap/issues/138
  nativeCheckInputs = lib.optionals stdenv.hostPlatform.isDarwin [ writableTmpDirAsHomeHook ];
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Official ICANN RDAP tools, containing cli client and server";
    mainProgram = "rdap";
    homepage = "https://github.com/icann/icann-rdap";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ paumr ];
  };
})
