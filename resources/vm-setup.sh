##!/bin/bash

# Last update:
# 09/14 - source .path (javap)
# 09/11 - conf. nano to show line numbers
# 09/10 - small typo, Heldion default config, javap
# 09/02 - updated Helidon CLI URL from 2.0.2 to 2.1.0 
# 08/29 - added nano XML support

# Fix OEL 'setlocale: LC_CTYPE: cannot change locale' warning
sudo -s eval 'printf 'LANG=en_US.utf-8\nLC_ALL=en_US.utf-8\n' > /etc/environment'

OPENJDK_URL="https://download.java.net/java/GA/jdk15/779bf45e88a44cbd9ea6621d33e33db1/36/GPL/openjdk-15_linux-x64_bin.tar.gz"
MAVEN_URL="https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
HELIDON_URL="https://github.com/oracle/helidon-build-tools/releases/download/2.1.0/helidon-cli-linux-amd64"
BAT_URL="https://github.com/sharkdp/bat/releases/download/v0.15.4/bat-v0.15.4-x86_64-unknown-linux-musl.tar.gz"

echo $'\n*** URLs ***\n'
echo "-> $OPENJDK_URL"
echo "-> $MAVEN_URL"
echo "-> $HELIDON_URL"

echo $'\n*** Installing git, tree, bat... ***\n'
sudo apt -y install git tree
mkdir -p $HOME/soft && curl -L $BAT_URL --output $HOME/soft/bat.tar.gz
mkdir -p $HOME/soft/bat && tar -xzvf $HOME/soft/bat.tar.gz -C $HOME/soft/bat --strip-components=1
export PATH=$HOME/soft/bat:$PATH

echo $'\n*** Installing OpenJDK 15... ***\n'
cd $HOME/soft && curl $OPENJDK_URL --output $HOME/soft/openjdk-15.tar.gz
tar -xzvf $HOME/soft/openjdk-15.tar.gz
sudo update-alternatives --install "/usr/bin/java" "java" "$HOME/soft/jdk-15/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "$HOME/soft/jdk-15/bin/javac" 1
export JAVA_HOME=$HOME/soft/jdk-15
echo "JAVA_HOME=$HOME/soft/jdk-15" >> $HOME/.bash_profile
java -version

echo $'\n*** Installing Maven... ***\n'
curl $MAVEN_URL --output $HOME/soft/maven.gz
cd ~/soft && tar -xzvf maven.gz
export PATH=$HOME/soft/apache-maven-3.6.3/bin:$PATH

echo $'\n*** Installing Helidon CLI... ***\n'
curl -L $HELIDON_URL --output $HOME/soft/helidon && chmod +x $HOME/soft/helidon
export PATH=$HOME/soft:$PATH
cd $HOME

echo $'\n*** Configuring firewall for port 8080... ***\n'
#sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
#sudo firewall-cmd --reload

# Set path
echo "PATH=$HOME/soft/bat:$HOME/soft/apache-maven-3.6.3/bin:$HOME/soft:$HOME/soft/jdk-15/bin/:$PATH" >> $HOME/.path
source .path
echo "source $HOME/.path" >> $HOME/.bash_profile

# Helidon default config
helidon version
sed -i 's/project.name=${init_archetype}-${init_flavor}/project.name=java-devlive/' ~/.helidon/config
sed -i 's/group.id=me.${user.name}-helidon/group.id=hol/' ~/.helidon/config
sed -i 's/artifact.id=${init_archetype}-${init_flavor}/artifact.id=demo/' ~/.helidon/config
sed -i 's/package.name=me.${user.name}.${init_flavor}.${init_archetype}/package.name=com.devlive/' ~/.helidon/config

