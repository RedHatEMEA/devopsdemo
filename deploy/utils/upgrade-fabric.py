#!/usr/bin/python

import json
import re
import requests
import sys
import time

endpoint = sys.argv[1] # http://localhost:8181/jolokia
name = sys.argv[2] # monster
version = sys.argv[3]

# Manual workaround to stop hibernate-osgi bundle

if name == "restapi":
  payload = {
    "operation": "getContainer(java.lang.String)",
    "type": "exec",
    "arguments": [ name ],
    "mbean": "io.fabric8:type=Fabric"
   }

  r = requests.post(endpoint, json.dumps(payload), auth = ("admin", "admin"))
  j = json.loads(r.text)

  container_endpoint = j["value"]["jolokiaUrl"]

  payload = {
    "type": "list"
  }

  r = requests.post(container_endpoint, json.dumps(payload), auth = ("admin", "admin"))
  j = json.loads(r.text)

  uuid = re.search("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", j["value"]["osgi.core"].keys()[0]).group(0)

  payload = {
    "operation": "listBundles()",
    "type": "exec",
    "mbean": "osgi.core:type=bundleState,version=1.7,framework=org.apache.felix.framework,uuid=%s" % uuid
  }

  r = requests.post(container_endpoint, json.dumps(payload), auth = ("admin", "admin"))
  j = json.loads(r.text)

  for bundle in j["value"]:
    if j["value"][bundle]["Headers"]["Bundle-Name"]["Value"] == "hibernate-osgi":
      break


  payload = {
    "operation": "stopBundle",
    "type": "exec",
    "arguments": [ bundle ],
    "mbean": "osgi.core:type=framework,version=1.7,framework=org.apache.felix.framework,uuid=%s" % uuid
  }

  requests.post(container_endpoint, json.dumps(payload), auth = ("admin", "admin"))

# Workaround ends

payload = {
    "operation": "applyVersionToContainers(java.lang.String, java.util.List)",
    "type": "exec",
    "arguments": [ version, [ name ] ],
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
