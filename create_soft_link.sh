#!/bin/bash

if [ -d /usr/lib/python2.7/dist-packages/nova/txt ];then
    echo "rm /usr/lib/python2.7/dist-packages/nova/txt"
    rm -rf /usr/lib/python2.7/dist-packages/nova/txt

fi

mkdir -p /usr/lib/python2.7/dist-packages/nova/txt

ln -s /usr/share/pyshared/nova/txt/__init__.py  /usr/lib/python2.7/dist-packages/nova/txt/__init__.py
ln -s /usr/share/pyshared/nova/txt/api.py  /usr/lib/python2.7/dist-packages/nova/txt/api.py
ln -s /usr/share/pyshared/nova/txt/attestionservice.py  /usr/lib/python2.7/dist-packages/nova/txt/attestionservice.py
ln -s /usr/share/pyshared/nova/txt/manager.py  /usr/lib/python2.7/dist-packages/nova/txt/manager.py
ln -s /usr/share/pyshared/nova/txt/txt_flags.py /usr/lib/python2.7/dist-packages/nova/txt/txt_flags.py
ln -s /usr/share/pyshared/nova/txt/txt.py  /usr/lib/python2.7/dist-packages/nova/txt/txt.py
ln -s /usr/share/pyshared/nova/cmd/txt.py /usr/lib/python2.7/dist-packages/nova/cmd/txt.py
