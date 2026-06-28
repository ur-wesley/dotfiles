{ config, pkgs, lib, ... }:

{
  # Dev tools
  home.packages = with pkgs; [
    # Task runner
    just

    # Container tools (CLI; Docker engine comes from Docker Desktop on Windows)
    docker
    docker-compose
    dive
    lazydocker
    podman
    buildkit
    skopeo

    # IaC
    opentofu
    pulumi
    ansible
    terraform

  # Build tools (mise still owns lang versions; this is for native compilation)
  gcc
  gnumake
  cmake
  ninja
  pkg-config
  python3
];

  # Docker socket bridge: in WSL, /var/run/docker.sock needs to be mapped from Windows
  # The Docker Desktop WSL integration handles this. As fallback, this is a stub.
  home.file.".docker/config".text = ''
    # Docker client config; engine is provided by Docker Desktop on Windows
    # via the named pipe //./pipe/docker_engine mapped into WSL.
  '';

  # Install opencode globally via mise-managed bun on every home-manager activation
  home.activation.installOpencode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v bun >/dev/null 2>&1; then
      if ! command -v opencode >/dev/null 2>&1; then
        run --quiet bun install -g opencode-ai
      fi
    fi
  '';

  # Install gentle-ai (Gentleman-Programming community AI stack) once on
  # first activation. Idempotent via a marker file in XDG_DATA_HOME so
  # the install script (curl | bash) doesn't re-run on every rebuild.
  # Re-install: rm ~/.local/share/gentle-ai/.installed-by-home-manager
  home.activation.installGentleAi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.local/share/gentle-ai/.installed-by-home-manager" ]; then
      mkdir -p "$HOME/.local/share/gentle-ai"
      run --quiet ${pkgs.curl}/bin/curl -fsSL \
        https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh \
        | ${pkgs.bash}/bin/bash
      touch "$HOME/.local/share/gentle-ai/.installed-by-home-manager"
    fi
  '';
}
