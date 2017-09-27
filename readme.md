# Run default test with volume
./bin/redkube pod_mark baz --cmd oc --sc gp2

# Run test without volumes
./bin/redkube pod_mark baz --cmd oc --sc gp2 --run PodNoVol


# Clone and run

https://github.com/gnufied/redkube.git

yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm

yum install -y jq
