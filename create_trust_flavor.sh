#!/bin/bash

source /root/openrc

nova flavor-create --ephemeral=0 --swap=0 --is-public=True m1.trust 6 4096 100 2
nova-manage flavor set_key --name m1.trust  --key trust:trusted_host --value trusted
