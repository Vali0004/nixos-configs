{ name ? ""
, port ? 9100
, targets ? [ "shitzen-nixos" ]
, interval ? "60s"
, appendNameToMetrics ? false
}:

let
  metrics_path = if appendNameToMetrics then "/${name}/metrics" else "/metrics";
in {
  job_name = name;
  scrape_interval = interval;
  inherit metrics_path;
  static_configs = map (t: {
    targets = [ "${t}:${toString port}" ];
    labels = { alias = t; };
  }) targets;
}