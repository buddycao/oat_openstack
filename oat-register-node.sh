#!/bin/bash
# This script will register this node with an Open Attestation Service

# OAT Server FQDN
#oat_svc_host=node4.sh.intel.com

# The IP we'll be contacting the OAT server *from* (could be a private IP)

if [ -z $oat_svc_host -o -z $ipaddr ]; then
    while [ "$1" != "${1##[-+]}" ]; do
      case $1 in
        '')    echo $"$0: Usage: $0 --oatserver=<fqdn oat server> --myip=<ip of nic contacting oatserver>}"
               exit 1;;
        --oatserver)
               oat_svc_host=$2
               shift 2
               ;;
        --oatserver=?*)
               oat_svc_host=${1#--oatserver=}
               shift
               ;;
        --myip)
               ipaddr=$2
               shift 2
               ;;
        --myip=?*)
               ipaddr=${1#--myip=}
               shift
               ;;
        *)     echo $"$0: Usage: $0 --oatserver=<fqdn oat server> --myip=<ip of nic contacting oatserver>}"
               exit 1;;
      esac
    done
fi

# Our hostname (just to be sure).
hostname=`hostname`

# Get some details of the system (hardware, OS, etc.) to enter into the OAT db
oem_manu=`dmidecode -s system-manufacturer`
oem_desc=`dmidecode -s system-product-name`


os=`cat /etc/redhat-release | awk -F"release" '{print $1}'`
os_ver=`cat /etc/redhat-release | awk -F"release" '{print $2}'`
vmm="KVM"
vmm_ver="1.6.2"
vmm_desc=$vmm
bios=`dmidecode -s bios-vendor`
bios_ver=`dmidecode -s bios-version`
bios_desc=`dmidecode -s baseboard-product-name`
pcr_00=`cat \`find /sys -name pcrs\` | grep PCR-00 | cut -c 8-80 | perl -pe 's/ //g'`
pcr_18=`cat \`find /sys -name pcrs\` | grep PCR-18 | cut -c 8-80 | perl -pe 's/ //g'`

echo \'$oat_svc_host\' \'$hostname\' \'$ipaddr\' \'$oem_manu\' \'$oem_desc\' \'$os\' \'$os_ver\' \'$os_desc\' \'$vmm\' \'$vmm_ver\' \'$vmm_desc\' \'$pcr_18\' \'$bios\' \'$bios_ver\' \'$bios_desc\' \'$pcr_00\'

bash CommandTool/oat_cert -h $oat_svc_host

# Enter the system hardware manufacturer (OEM) into the oat_db
bash CommandTool/oat_oem -a -h $oat_svc_host "{\"Name\":\"$oem_manu\",\"Description\":\"$oem_desc\"}"

# Enter the operating sytem into the oat_db (RH-like systems only)
bash CommandTool/oat_os -a -h $oat_svc_host "{\"Name\":\"$os\",\"Version\":\"$os_ver\",\"Description\":\"$os_desc\"}"

# Enter VMM measured launch environment (mle) into the oat_db
bash CommandTool/oat_mle -a -h $oat_svc_host "{\"Name\":\"$vmm\",\"Version\":\"$vmm_ver\",\"OsName\":\"$os\",\"OsVersion\":\"$os_ver\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"VMM\",\"Description\":\"$vmm_desc\",\"MLE_Manifests\":[{\"Name\":\"18\",\"Value\":\"$pcr_18\"}]}"

# Enter BIOS managed launch environment (mle) into the oat_db
bash CommandTool/oat_mle -a -h $oat_svc_host "{\"Name\":\"$bios\",\"Version\":\"$bios_ver\",\"OemName\":\"$oem_manu\",\"Attestation_Type\": \"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$bios_desc\",\"MLE_Manifests\":[{\"Name\":\"0\",\"Value\":\"$pcr_00\"}]}"

# add the host to the database
bash CommandTool/oat_host -a -h $oat_svc_host "{\"HostName\":\"$hostname\",\"IPAddress\":\"$ipaddr\",\"Port\":\"9999\",\"BIOS_Name\":\"$bios\",\"BIOS_Version\":\"$bios_ver\",\"BIOS_Oem\":\"$oem_manu\",\"VMM_Name\":\"$vmm\",\"VMM_Version\":\"$vmm_ver\",\"VMM_OSName\":\"$os\",\"VMM_OSVersion\":\"$os_ver\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"

# attest the host
bash CommandTool/oat_pollhosts -h $oat_svc_host "{\"hosts\":[\"$hostname\"]}" | grep trusted &> /dev/null

if [ $? -eq 0 ]; then \
       echo "Node Attestation Successful!"
       exit 0
else
       echo "Node Attestation Failed!"
       exit 1
fi
