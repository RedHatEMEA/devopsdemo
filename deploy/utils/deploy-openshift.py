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
    endpoint = sys.argv[1] # "https://10.33.7.66/broker/rest"
    name = sys.argv[2] # jbosseap
    baseurl = sys.argv[3] # "http://10.33.7.1/cxf/"
    artifact_url = sys.argv[4]

    api = API(endpoint, ("demo", "demo"), verify = False)
    id = api.application_create("demo", 
                                name = name,
                                cartridges = "jbosseap-6",
                                gear_size = "small",
                                environment_variables = [{"name": "BASEURL",
                                                          "value": baseurl}])

    api.application_deploy(id, artifact_url = artifact_url)

    print "https://%s-demo.ose.saleslab.fab.redhat.com" % name
