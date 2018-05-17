#!/bin/bash

set -v

dir="$(dirname "$0")"

go get -f -u github.com/axw/gocov/gocov
go get -f -u github.com/mattn/goveralls
go get -f -u golang.org/x/tools/cmd/cover

sudo systemctl stop etcd.service
sleep 15

sudo iptables -F
sudo iptables -P FORWARD ACCEPT
for i in $(find /proc/sys/net/bridge/ -type f) ; do echo 0 | sudo tee $i ; done

set -e

cd ${GOPATH}/src/github.com/skydive-project/skydive

[ -d /tmp/netcleanup ] || sudo scripts/ci/cleanup.sh init
export ARGS="-graph.output ascii"
./coverage.sh --no-functionals --no-scale
sudo scripts/ci/cleanup.sh snapshot
sudo scripts/ci/cleanup.sh cleanup
./coverage.sh --no-units --no-scale
sudo scripts/ci/cleanup.sh snapshot
sudo scripts/ci/cleanup.sh cleanup
./coverage.sh --no-units --no-scale --orientdb
sudo scripts/ci/cleanup.sh snapshot
sudo scripts/ci/cleanup.sh cleanup
./coverage.sh --no-units --no-functionals --coveralls
