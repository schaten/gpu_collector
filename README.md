# Tiny nvidia_smi-based GPU collector for node_exporter

To activate metric collection,
1) `install.sh` and
2) add `--collector.textfile.directory /tmp/text_metrics` to your node-exporter cmdline.
   Under Debian, this is done by editing `/etc/default/prometheus-node-exporter`
