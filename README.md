# DevOps demo 0.1

Jim Minter <jminter@redhat.com>, 29/09/2014

### Prerequisites

* You'll need access to an OpenStack tenant.
* You'll need to clone https://github.com/RedHatEMEA/devopsdemo.git into your own Git repository.

### Getting started

1. Download a `keystonerc` file from your OpenStack tenant (hint: log in to Horizon (the OpenStack web interface) and navigate to http://openstack-hostname/dashboard/project/access_and_security/api_access/openrc/ to download).  This file **must** be placed in the root directory of this project and named keystonerc.

1. Run `infrastructure_setup.sh` to prepare the OpenStack tenant.  This should need only ever to be run once per tenant:

   ```bash
   $ . keystonerc
   (devopsdemo)$ cd deploy
   (devopsdemo)$ ./infrastructure_setup.sh
   ```

   This will do the following:

   * (Re)create a OpenStack security group called devopsdemo, set up rules as required
   * Upload `~/.ssh/id_rsa.pub` as a nova keypair named `$USER`
   * Guess(!) the UUID of the Neutron public network and store this in `infrastructure/environment.yaml`

1. Run `infrastructure_install.sh` to install the DNS server, OpenShift infrastructure and Jenkins/Nexus infrastructure using OpenStack Heat.  You will need to provide the URL to your cloned devopsdemo Git repository:

   ```bash
   $ . keystonerc
   (devopsdemo)$ cd deploy
   (devopsdemo)$ GIT_URL=https://path/to/devopsdemo.git ./infrastructure_install.sh
   ...
   DNS_IP=www.xxx.yyy.zzz
   ...
   ```

1. The previous step will output the IP address of the newly created DNS server instance.  Set up your local DNS resolver (/etc/resolv.conf) to point to this IP address:

   ```bash
   $ sudo echo nameserver www.xxx.yyy.zzz >/etc/resolv.conf
   ```

1. Navigate to [Jenkins](http://ci.demo/jenkins) and wait for the first application build and test to complete successfully.

1. Run application_install.sh to deploy the "production" instance of your application using OpenStack Heat:

   ```bash
   $ . keystonerc
   (devopsdemo)$ cd deploy
   (devopsdemo)$ PREFIX=prod VERSION=0.1-1 ./application_install.sh
   ```
