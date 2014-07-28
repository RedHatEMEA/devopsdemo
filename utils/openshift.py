#!/usr/bin/python

import json
import requests
import sys


class API(object):
    def __init__(self, url, auth, verify=True):
        self.s = requests.Session()
        self.url = url
        self.auth = auth
        self.verify = verify

    def _call(self, method, url, data=None):
        r = self.s.request(method, self.url + url, data=data,
                           headers={"Content-Type": "application/json"},
                           auth=self.auth, verify=self.verify)

        if r.status_code / 100 != 2:
            raise Exception("Unexpected HTTP status code %u" % r.status_code)

        return json.loads(r.content)["data"]

    def application_create(self, domain, **kwargs):
        r = self._call("POST", "/domain/%s/applications" % domain,
                       json.dumps(kwargs))

        return r["id"]

    def application_info(self, id):
        return self._call("GET", "/application/%s" % id)

    def application_delete(self, id):
        return self._call("DELETE", "/application/%s" % id)

    def application_deploy(self, id, **kwargs):
        return self._call("POST", "/application/%s/deployments" % id,
                          json.dumps(kwargs))


if __name__ == "__main__":
    # still need to set up initial domain...  ssh keys?
    api = API("https://10.33.7.66/broker/rest", ("demo", "demo"), verify = False)
    id = api.application_create("demo", 
                                name = "jbosseap",
                                cartridges = "jbosseap-6",
                                gear_size = "small",
                                environment_variables = [{"name": "BASEURL",
                                                          "value": sys.argv[1]}])

    print id
    api.application_deploy(id, artifact_url="http://10.33.11.12:8081/nexus/content/repositories/snapshots/com/redhat/ticketmonster/webapp/0.1-SNAPSHOT/webapp-0.1-20140728.102124-4.tar.gz")
