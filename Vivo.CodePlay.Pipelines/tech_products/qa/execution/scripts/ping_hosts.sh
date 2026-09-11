#!/bin/bash

apt-get update -y
apt-get install -y iputils-ping

ping -c 4 10.129.163.105
host brtlvlty0261pl