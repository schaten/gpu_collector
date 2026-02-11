#!/bin/bash

mkdir -p /opt
cp gpu_collector.sh /opt
cp gpu_collector.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now gpu_collector
