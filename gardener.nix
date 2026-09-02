{ ... }:

{
  services.resolved.settings = {
    Resolve = {
      DNS = "172.18.255.53 fd00:ff::53";
      Domains = "~local.gardener.cloud";
    };
  };

  networking.extraHosts = ''
    127.0.0.1 registry.local.gardener.cloud
    ::1 registry.local.gardener.cloud

    127.0.0.1 dexidp
    127.0.0.1 plutono-garden.ingress.local.seed.local.gardener.cloud
    127.0.0.1 prometheus-seed-garden-0.ingress.local.seed.local.gardener.cloud
    127.0.0.1 prometheus-aggregate-garden-0.ingress.local.seed.local.gardener.cloud
    127.0.0.1 prometheus-cache-garden-0.ingress.local.seed.local.gardener.cloud
    127.0.0.1 vlsingle-victoria-logs-garden.ingress.local.seed.local.gardener.cloud
    127.0.0.1 prometheus-shoot-shoot--local--local-0.ingress.local.seed.local.gardener.cloud
    127.0.0.1 plutono-shoot--local--local.ingress.local.seed.local.gardener.cloud
    127.0.0.1 vlsingle-victoria-logs-shoot--local--local.ingress.local.seed.local.gardener.cloud
  '';

  virtualisation.docker.daemon.settings = {
    insecure-registries = [ "registry.local.gardener.cloud:5001" ];
  };
}
