self: super: {
  lib = super.lib // {
    mkPrometheusJob = { name ? ""
    , port ? 9100
    , targets ? [ "shitzen-nixos" ]
    , interval ? "60s"
    , appendNameToMetrics ? false
    }: {
      job_name = name;
      scrape_interval = interval;
      metrics_path = if appendNameToMetrics then "/${name}/metrics" else "/metrics";
      static_configs = map (t: {
        targets = [ "${t}:${toString port}" ];
        labels = { alias = t; };
      }) targets;
    };
  };
}