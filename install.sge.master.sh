# this script installs and configures SGE on the master node of the cluster
# it include two major parts: (1) install the SGE packages (2) configure the mater node

# part 1: installation of SGE packages
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false update
sudo DEBIAN_FRONTEND=noninteractive apt-get install debconf-utils -y # for apt-get unattended installations

echo "gridengine-qmon       shared/gridenginemaster string  gwb-grid-mm" | sudo debconf-set-selections
echo "gridengine-qmon       shared/gridengineconfig boolean true" | sudo debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt-get install gridengine-common gridengine-client gridengine-qmon gridengine-master -y

# part 2: configuration of SGE master node
sudo sudo -u sgeadmin qconf -am $USER
qconf -au $USER users
qconf -as $(hostname)

# create a host list (this is not as straightforward as "qconf -ahgrp", but avoids the user interaction)
echo -e "group_name @allhosts\nhostlist NONE" > ./grid
sudo qconf -Ahgrp ./grid
rm ./grid

qconf -aattr hostgroup hostlist $(hostname) @allhosts

# create a queue (this is even more complicated than a straightforward "qconf -aq", but avoids the user interaction)
# note: qname, hostlist, load_thresholds
cat > ./grid <<EOL
qname                 main.q
hostlist              @allhosts
seq_no                0
load_thresholds       NONE
suspend_thresholds    NONE
nsuspend              1
suspend_interval      00:00:01
priority              0
min_cpu_interval      00:00:01
processors            UNDEFINED
qtype                 BATCH INTERACTIVE
ckpt_list             NONE
pe_list               make
rerun                 FALSE
slots                 2
tmpdir                /tmp
shell                 /bin/csh
prolog                NONE
epilog                NONE
shell_start_mode      posix_compliant
starter_method        NONE
suspend_method        NONE
resume_method         NONE
terminate_method      NONE
notify                00:00:01
owner_list            NONE
user_lists            NONE
xuser_lists           NONE
subordinate_list      NONE
complex_values        NONE
projects              NONE
xprojects             NONE
calendar              NONE
initial_state         default
s_rt                  INFINITY
h_rt                  INFINITY
s_cpu                 INFINITY
h_cpu                 INFINITY
s_fsize               INFINITY
h_fsize               INFINITY
s_data                INFINITY
h_data                INFINITY
s_stack               INFINITY
h_stack               INFINITY
s_core                INFINITY
h_core                INFINITY
s_rss                 INFINITY
h_rss                 INFINITY
s_vmem                INFINITY
h_vmem                INFINITY
EOL
sudo qconf -Aq ./grid
rm ./grid

qconf -aattr queue slots "4, [$(hostname)=3]" main.q

qconf -as gwb-grid-ww-0
qconf -as gwb-grid-ww-1
qconf -aattr hostgroup hostlist gwb-grid-ww-0 @allhosts
qconf -aattr hostgroup hostlist gwb-grid-ww-1 @allhosts

# install Java
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-7-jre
java -version 2> java.version.txt
