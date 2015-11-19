# oat_openstack

The goal of the project is to provide VM level attestation in OpenStack. It leverages the projects including OpenStack, OpenAttestation and Intel TXT. The success criteria is to create instance on trusted host within OpenStack environment.


## Deploy

Fuel 6.0/6.1 with both OS, Ubuntu/CentOS, are suitable. The neutron is enabled with GRE mode. A node installed Ubuntu 14.04 is be used to setup OpenAttestation server. There are three branches for the repo.

```bash
git branch -a
  fuel-centos
  fuel6.0-ubuntu
  fuel6.1-ubuntu
  master
```

Fuel-centos branch works for CentOS both Fuel 6.0 and 6.1, while the rest be used for Ubuntu of Fuel 6.0 and Fuel 6.1

Please refer to file UserGuide.pdf for the usage in details.

