ROOT_PARTITION=$(cat dmp.properties | grep "ROOT_PARTITION" | awk -F = '{print $2}' | awk '{print $1}')
INSTANCE=$(cat dmp.properties | grep "INSTANCE" | awk -F = '{print $2}' | awk '{print $1}')
Instance_NAME=$(cat dmp.properties | grep "Instance_NAME" | awk -F = '{print $2}' | awk '{print $1}')
HOST_IP=$(ifconfig | grep "inet addr" | head -1 | awk '{print $2}' | awk -F : '{print $2}')
AEM_HOSTNAME=$(nslookup $HOST_IP | grep "name = " | awk '{print $NF}' | sed s'/.$//')
ARCHIVE_PATH=$(echo "$ROOT_PARTITION/archive/dmp")
 
#update PATH variable
printf "Update bash parameters"
echo '# .bash_profile
 
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi
 
# User specific environment and startup programs
 
PATH=/app/aem/java/jdk1.8.0_112/bin:/app/aem/openssl/bin:$PATH:$HOME/bin:/sbin
 
export PATH
 
LD_LIBRARY_PATH="/app/aem/openssl/lib:$LD_LIBRARY_PATH"
 
export LD_LIBRARY_PATH' > /app1/archive/dmp/.bash_profile
 
echo "updating umask"
echo "umask 027" >> /app1/archive/dmp/.bashrc
 
#create required diretories
if [[ ! -d $ROOT_PARTITION/dmp ]]
then
        echo "$ROOT_PARTITION/dmp does not exist. "
        mkdir $ROOT_PARTITION/dmp; #chown dmp $ROOT_PARTITION/dmp; chgrp dmpgrp $ROOT_PARTITION/dmp
        mkdir $ROOT_PARTITION/dmp/scripts
        mkdir $ROOT_PARTITION/dmp/scripts/logs
fi
 
if [[ ! -d $ROOT_PARTITION/dmp/scripts ]]
then
        mkdir $ROOT_PARTITION/dmp/scripts
        mkdir $ROOT_PARTITION/dmp/scripts/logs
fi
 
if [[ ! -d $ROOT_PARTITION/archive/dmp ]]
then
        mkdir $ROOT_PARTITION/archive/dmp; #chown dmp $ROOT_PARTITION/archive/dmp; chgrp dmpgrp $ROOT_PARTITION/archive/dmp
fi
 
if [[ $INSTANCE == "publish" ]]
then
        AEM_PORT=4507
        PUBLISH_PATH=$(echo "$ROOT_PARTITION/dmp/$Instance_NAME")
        #download publish-cq, Java
 
        cd $ARCHIVE_PATH
        #Download java
        echo "Downloading publish from http://dmfctoolsdr.aig.net:7080/nexus/content/repositories/config/com/aig/dmp/deploy/1.2/deploy-1.2.zip"
        wget http://dmfctoolsdr.aig.net:7080/nexus/content/repositories/config/com/aig/dmp/deploy/1.2/deploy-1.2.zip
        #download Publish
        #wget "http://10.91.209.121:8081/"
        #download openssl
        #wget "http://10.91.209.121:8081/"
 
        cd $ROOT_PARTITION/dmp
        unzip $ARCHIVE_PATH/publish.zip    #to be replaced with su -dmp -c "unzip $ARCHIVE_PATH/publish.zip"
        mv $ROOT_PARTITION/dmp/publish $PUBLISH_PATH
        cd $PUBLISH_PATH
        sed -i "s/AEM_HOSTNAME/$AEM_HOSTNAME/g" crx-quickstart/bin/start
        sed -i "s/AEM_PORT/$AEM_PORT/g" crx-quickstart/bin/start
        sed -i "s/PUBLISH_PATH/$PUBLISH_PATH/g" crx-quickstart/bin/start
 
        chmod 755 $PUBLISH_PATH/
        chmod 755 $PUBLISH_PATH/crx-quickstart
        chmod 755 $PUBLISH_PATH/crx-quickstart/logs
fi
