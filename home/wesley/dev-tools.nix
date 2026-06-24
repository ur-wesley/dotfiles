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

    # Kubernetes
    kubectl
    kubectx
    stern
    k9s
    helm
    kustomize
    argocd
    fluxcd

    # Cloud CLIs
    awscli2
    azure-cli
    google-cloud-sdk
    doctl
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
}
