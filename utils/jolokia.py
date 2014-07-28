#!/bin/python

import json
import requests
import sys
import time

endpoint=sys.argv[1] # "http://localhost:8181/jolokia"

payload = {
    'operation': 'createContainers(java.util.Map)',
    'type': 'exec',
    'arguments': [{
	    'name': 'monster',
	    'parent': 'root',
	    'providerType': 'child',
	    'profiles': ['ticketmonster'],
	    'version': '1.0',
	    'jmxUser': 'admin',
	    'jmxPassword': 'admin'}],
    'mbean': 'io.fabric8:type=Fabric'
}

requests.post(endpoint, json.dumps(payload), auth = ("admin", "admin"))

payload = {
    'operation': 'getContainer(java.lang.String)',
    'type': 'exec',
    'arguments': [ 'monster' ],
    'mbean': 'io.fabric8:type=Fabric'
}

while True:
  r = requests.post(endpoint, json.dumps(payload), auth = ("admin", "admin"))
  j = json.loads(r.text)

  if j["value"]["provisionStatus"] == "success" and j["value"]["alive"]:
    print "CXF_URL=" + j["value"]["httpUrl"]
    break

  time.sleep(2)
