#!/bin/bash

sudo swapoff -a
sudo dd if=/dev/zero of=/var/swapfile bs=1M count=1024
sudo mkswap /var/swapfile
sudo chmod 600 /var/swapfile
sudo swapon /var/swapfile
sudo swapon -s

# free -mh