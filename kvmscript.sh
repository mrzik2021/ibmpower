#!/bin/bash
set -x
#create tenant folder
groups=$(groups | awk '{print $2}')
mkdir /vmdata/$groups
setfacl -m g:$groups:rwx /vmdata/$groups
setfacl -d -m g:$groups:rwx /vmdata/$groups
#config tenant vmnetwork
cat << EOF > netbridge.xml
<network>
    <name>vmnetwork</name>
    <forward mode="bridge" />
    <bridge name="bridge0" />
</network>
EOF
virsh net-define ./netbridge.xml
virsh net-start vmnetwork
virsh net-autostart vmnetwork
#config tenant vmiso
cat << EOF > vmiso.xml
<pool type='dir'>
  <name>VM-ISO</name>
  <target>
    <path>/iso</path>
  </target>
</pool>
EOF
virsh pool-define ./vmiso.xml
virsh pool-start VM-ISO
virsh pool-autostart VM-ISO
#config tenant vmdata
cat << EOF > vmdata.xml
<pool type='dir'>
  <name>VM-DATA</name>
  <target>
    <path>/vmdata/$groups</path>
  </target>
</pool>
EOF
virsh pool-define ./vmdata.xml
virsh pool-start VM-DATA
virsh pool-autostart VM-DATA


