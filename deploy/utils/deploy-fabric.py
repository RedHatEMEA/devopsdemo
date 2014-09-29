#!/usr/bin/python

import json
import requests
import sys
import time

endpoint = sys.argv[1] # http://localhost:8181/jolokia
profile = sys.argv[2] # ticketmonster
name = sys.argv[3] # monster
version = sys.argv[4]

payload = {
    "operation": "createContainers(java.util.Map)",
    "type": "exec",
    "arguments": [{
	    "name": name,
	    "parent": "root",
	    "providerType": "child",
	    "profiles": [ profile ],
	    "version": version,
	    "jmxUser": "admin",
	    "jmxPassword": "admin"}],
    "mbean": "io.fabric8:type=Fabric"
}

requests.post(endpoint, json.dumps(payload), auth = ("admin", "admin"))

payload = {
    "operation": "getContainer(java.lang.String)",
    "type": "exec",
    "arguments": [ name ],
    "mbean": "io.fabric8:type=Fabric"
}

while True:
  r = requests.post(endpoint, json.dumps(payload), auth = ("admin", "admin"))
  j = json.loads(r.text)

  if "value" in j and j["value"]["provisionStatus"] == "success" and j["value"]["alive"]:
    print "CONTAINER_URL=" + j["value"]["httpUrl"]
    break

  time.sleep(2)
