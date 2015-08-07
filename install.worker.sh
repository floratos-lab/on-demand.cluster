# install and set up SGE worker node
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false update

# unattended
echo "gridengine-exec       shared/gridenginemaster string  gwb-grid-mm" | sudo debconf-set-selections
echo "gridengine-exec       shared/gridengineconfig boolean true" | sudo debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes gridengine-client gridengine-exec

# install Java
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-7-jre
java -version 2> java.version.txt
