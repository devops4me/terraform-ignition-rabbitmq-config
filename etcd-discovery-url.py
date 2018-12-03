#!/usr/bin/env python

# -----------------------------------------------------------------------------------------------
# https://github.com/devops4me/terraform-ignition-etcd-config/blob/master/etcd-discovery-url.py
# -----------------------------------------------------------------------------------------------
#
# Here are the important items to note before running or
# when trouble-shooting this script.
#
#  [1] - the [requests] package must be installed before running this
#        script. For CI this is done inside the Dockerfile.
#          $ pip install requests
#
#  [2] - it pays to give this script execute permissions
#          $ chmod u+x etcd-discovery-url.py
#
#  [3] - try out this script from its directory with these commands
#          $ python etcd-discovery-url.py 3
#          $ ./etcd-discovery-url.py 3
#
#  [4] - an invalid syntax error "json.dumps" occurs if python3 used
#
#  [5] - it expects number of nodes in the cluster as the first parameter
#
#  [6] - output is a JSON formatted string with key "etcd_discovery_url"
#
#  [7] - Example Command and Output
#
#          $ ./etcd-discovery-url.py 3
#          {"etcd_discovery_url": "https://discovery.etcd.io/a660b68aa151605f0ed32807b4be165f"}

import requests, json, sys
response = requests.get( 'https://discovery.etcd.io/new', params={ 'size' : sys.argv[1] } )
print json.dumps( { "etcd_discovery_url" : response.text } )
