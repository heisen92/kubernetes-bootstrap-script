#!/bin/bash
echo "[TASK 0] SHOW WHOAMI"
whoami
sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
service systemd-resolved restart