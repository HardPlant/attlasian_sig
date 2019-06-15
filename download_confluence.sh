#!/bin/bash
sudo su
mkdir /var/confluence
wget --quiet https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-6.15.4-x64.bin -P /var/confluence
cd /var/confluence
chmod u+x atlassian-confluence-6.15.4-x64.bin
#./atlassian-confluence-6.15.4-x64.bin