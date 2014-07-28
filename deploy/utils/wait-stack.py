#!/usr/bin/python

import os
import sys
import time
from heatclient import client as heatclient
from heatclient.common import template_utils
from keystoneclient.v2_0 import client as ksclient

def getclient():
  ks = ksclient.Client(auth_url = os.environ["OS_AUTH_URL"],
                       tenant_name = os.environ["OS_TENANT_NAME"],
                       username = os.environ["OS_USERNAME"],
                       password = os.environ["OS_PASSWORD"])
  
  heat_url = ks.service_catalog.get_urls(service_type = "orchestration")[0]

  return heatclient.Client("1", endpoint = heat_url, token = ks.auth_token,
                           username = os.environ["OS_USERNAME"],
                           password = os.environ["OS_PASSWORD"])


hc = getclient()

def wait(hc, id):
  while True:
    stack = hc.stacks.get(id)
    if stack.stack_status != "CREATE_IN_PROGRESS":
      for o in stack.outputs:
        print "%s=%s" % (o["output_key"], o["output_value"])
      return stack.stack_status

    time.sleep(5)

if __name__ == "__main__":
  status = wait(hc, sys.argv[1])
  sys.exit(status != "CREATE_COMPLETE")
