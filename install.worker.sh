# install and set up SGE worker node
sudo apt-get update

# unattended
echo "gridengine-exec       shared/gridenginemaster string  gwb-grid-mm" | sudo debconf-set-selections
echo "gridengine-exec       shared/gridengineconfig boolean true" | sudo debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes gridengine-client gridengine-exec
