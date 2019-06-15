#!/bin/bash

mkdir /var/jira
wget --quiet https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.2.1-x64.bin -P /var/jira
cd /var/jira
chmod u+x atlassian-jira-software-8.2.1-x64.bin
./atlassian-jira-software-8.2.1-x64.bin