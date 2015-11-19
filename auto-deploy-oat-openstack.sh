#!/bin/bash

# The scripte is used to configure OpenStack with OpenAttesation.
# Before apply the scripte, please ensure you have the OpenAttestation
# environment ready, including the server and client.

PATCH_DIR=`pwd`
echo $PATCH_DIR

usage()
{
   echo "Usage: $0 --oatserver=<IP of oat server> --computingnode=hostname1,hostname2,hostname3,....}"
}

##### Handle Paramters #######################

while [ "$1" != "${1##[-+]}" ]; do
  case $1 in
    '')    echo $"$0: Usage: $0 --oatserver=<IP of oat server> --computingnode=hostname1,hostname2,hostname3,....}"
           exit 1;;
    --oatserver)
           oat_svc_host=$2
           shift 2
           ;;
    --oatserver=?*)
           oat_svc_host=${1#--oatserver=}
           shift
           ;;
    --computingnode)
           hosts=$2
           shift 2
           ;;
    --computingnode=?*)
           hosts=${1#--computingnode=}
           shift
           ;;
    *)     echo $"$0: Usage: $0 --oatserver=<IP of oat server> --computingnode=hostname1,hostname2,hostname3,....}"
           exit 1;;
  esac
done

echo $oat_svc_host
echo $hosts

##### Configure nova-txt config file ##################
CONTROLLER_NAME=`hostname`

sed -i "s/\$CONTROLLER_HOSTNAME/$CONTROLLER_NAME/g" $PATCH_DIR/nova-txt.conf
sed -i "s/\$OAT_SERVER_IP/$oat_svc_host/g" $PATCH_DIR/nova-txt.conf

if [ -f /etc/nova/nova-txt.conf ]; then
    echo "Detected previous nova-txt config file, deleting"
    rm -f /etc/nova/nova-txt.conf
fi

if [ ! -f /etc/nova/certfile.cer ]; then
    echo "Cert file certfile.cer not found, exiting"
    exit 1
fi

cp $PATCH_DIR/nova-txt.conf /etc/nova/nova-txt.conf
cp $PATCH_DIR/nova-txt /usr/bin/nova-txt

##### Apply Nova/Horizon patch on Controller Node ########################
yum install -y patch --disablerepo=base
cd /usr/share/openstack-dashboard
patch -p1 < $PATCH_DIR/0001-OpenAttestion-intergration-with-Horizon-v1.patch
cd /usr/lib/python2.6/site-packages
patch -p1 < $PATCH_DIR/0001-OpenAttestion-intergration-with-Nova-v1.patch
cd $PATCH_DIR

##### Restart OpenStack Nova services #################
bash $PATCH_DIR/restart-nova.sh controller

##### Restart Horizon service #########################
service httpd restart

##### Create trust flavor #############################
echo "Sleeping 5 seconds and waiting for httpd restarting!"
sleep 5
bash $PATCH_DIR/create_trust_flavor.sh

##### OpenStack Controller Node Done #################
echo 'Controller Node Settings Done!!' 


##### Changes to Computing Nodes ######################

##### Copy needed files to Computing Node ###########
##### Remote Execut ############

if [ -d $PATCH_DIR/computingnode ]; then
    echo "Found previous computingnode folder, deleting"
    rm -rf $PATCH_DIR/computingnode
fi
mkdir $PATCH_DIR/computingnode

cp $PATCH_DIR/*.patch $PATCH_DIR/computingnode/
cp $PATCH_DIR/nova-txt* $PATCH_DIR/computingnode/
cp $PATCH_DIR/restart-nova.sh $PATCH_DIR/computingnode/

IFS=, HOSTS=($hosts)

for index in ${HOSTS[@]};do
    echo $index
    scp -r $PATCH_DIR/computingnode root@$index:/tmp/
    ssh root@$index "yum install -y patch --disablerepo=base; \
cp /tmp/computingnode/nova-txt.conf /etc/nova; \
cp /tmp/computingnode/nova-txt /usr/bin/; \
cd /usr/lib/python2.6/site-packages; \
patch -p1 < /tmp/computingnode/0001-OpenAttestion-intergration-with-Nova-v1.patch; \
bash /tmp/computingnode/restart-nova.sh compute; \
"
done

##### OpenStack Computing Node(s) Done ################
echo 'Computing Node(s) Settings Done!!'

