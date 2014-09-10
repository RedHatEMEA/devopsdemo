#!/bin/bash -x

SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}
PROXY_IP_ADDR=${PROXY_IP_ADDR:-10.33.11.12}
GIT_URL=${GIT_URL:-https://github.com/RedHatEMEA/devopsdemo.git}

LOCAL_IP_ADDR=$(ifconfig eth0 | sed -ne '/inet addr:/ { s/.*inet addr://; s/ .*//; p }')
FLOATING_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

fix_gso() {
  cat >>/etc/rc.local <<EOF
ethtool -K eth0 gso off
ethtool -K eth0 tso off
EOF

  ethtool -K eth0 gso off
  ethtool -K eth0 tso off
}

set_tz() {
  ln -sf /usr/share/zoneinfo/$1 /etc/localtime 
}

register_channels() {
  for CHANNEL in $*
  do
    curl -so /etc/yum.repos.d/$CHANNEL.repo http://$SATELLITE_IP_ADDR:8085/$CHANNEL.repo
  done
}

install_packages() {
  python -u /usr/bin/yum -y install $*
}

disable_firewall() {
  service iptables stop
  chkconfig iptables off
}

maven_install() {
  curl -s http://$PROXY_IP_ADDR/apache-maven-3.2.3-bin.tar.gz | (cd /usr/local && tar -xz)
}

register_hostname() {
  echo 127.0.0.1   $(hostname) >>/etc/hosts
}

nexus_install() {
  curl -s http://$PROXY_IP_ADDR/nexus-2.9.1-02-bundle.tar.gz | (cd /usr/local && tar -xz)

  cat >>/etc/rc.local <<EOF
RUN_AS_USER=root $(echo /usr/local/nexus-*/bin)/nexus start
EOF
}

nexus_configure() {
  mkdir /usr/local/sonatype-work/nexus/conf
  cat >/usr/local/sonatype-work/nexus/conf/nexus.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<nexusConfiguration>
  <version>2.8.0</version>
  <nexusVersion>2.9.1-02</nexusVersion>
  <globalConnectionSettings>
    <connectionTimeout>20000</connectionTimeout>
    <retrievalRetryCount>3</retrievalRetryCount>
    <queryString></queryString>
  </globalConnectionSettings>
  <restApi>
    <uiTimeout>60000</uiTimeout>
  </restApi>
  <httpProxy>
    <enabled>true</enabled>
    <port>8082</port>
    <proxyPolicy>strict</proxyPolicy>
  </httpProxy>
  <routing>
    <resolveLinks>true</resolveLinks>
  </routing>
  <repositories>
    <repository>
      <id>releases</id>
      <name>Releases</name>
      <providerRole>org.sonatype.nexus.proxy.repository.Repository</providerRole>
      <providerHint>maven2</providerHint>
      <localStatus>IN_SERVICE</localStatus>
      <notFoundCacheTTL>1440</notFoundCacheTTL>
      <userManaged>true</userManaged>
      <exposed>true</exposed>
      <browseable>true</browseable>
      <writePolicy>ALLOW_WRITE_ONCE</writePolicy>
      <indexable>true</indexable>
      <searchable>true</searchable>
      <localStorage>
        <provider>file</provider>
      </localStorage>
      <externalConfiguration>
        <proxyMode>ALLOW</proxyMode>
        <artifactMaxAge>-1</artifactMaxAge>
        <itemMaxAge>1440</itemMaxAge>
        <cleanseRepositoryMetadata>false</cleanseRepositoryMetadata>
        <downloadRemoteIndex>false</downloadRemoteIndex>
        <checksumPolicy>WARN</checksumPolicy>
        <repositoryPolicy>RELEASE</repositoryPolicy>
      </externalConfiguration>
    </repository>
    <repository>
      <id>snapshots</id>
      <name>Snapshots</name>
      <providerRole>org.sonatype.nexus.proxy.repository.Repository</providerRole>
      <providerHint>maven2</providerHint>
      <localStatus>IN_SERVICE</localStatus>
      <notFoundCacheTTL>1440</notFoundCacheTTL>
      <userManaged>true</userManaged>
      <exposed>true</exposed>
      <browseable>true</browseable>
      <writePolicy>ALLOW_WRITE</writePolicy>
      <indexable>true</indexable>
      <searchable>true</searchable>
      <localStorage>
        <provider>file</provider>
      </localStorage>
      <externalConfiguration>
        <proxyMode>ALLOW</proxyMode>
        <artifactMaxAge>1440</artifactMaxAge>
        <itemMaxAge>1440</itemMaxAge>
        <cleanseRepositoryMetadata>false</cleanseRepositoryMetadata>
        <downloadRemoteIndex>false</downloadRemoteIndex>
        <checksumPolicy>WARN</checksumPolicy>
        <repositoryPolicy>SNAPSHOT</repositoryPolicy>
      </externalConfiguration>
    </repository>
    <repository>
      <id>public</id>
      <name>Public Repositories</name>
      <providerRole>org.sonatype.nexus.proxy.repository.GroupRepository</providerRole>
      <providerHint>maven2</providerHint>
      <localStatus>IN_SERVICE</localStatus>
      <notFoundCacheTTL>15</notFoundCacheTTL>
      <userManaged>true</userManaged>
      <exposed>true</exposed>
      <browseable>true</browseable>
      <writePolicy>READ_ONLY</writePolicy>
      <indexable>true</indexable>
      <localStorage>
        <provider>file</provider>
      </localStorage>
      <externalConfiguration>
        <mergeMetadata>true</mergeMetadata>
        <memberRepositories>
          <memberRepository>releases</memberRepository>
          <memberRepository>snapshots</memberRepository>
          <memberRepository>root</memberRepository>
        </memberRepositories>
      </externalConfiguration>
    </repository>
    <repository>
      <id>root</id>
      <name>Root</name>
      <providerRole>org.sonatype.nexus.proxy.repository.Repository</providerRole>
      <providerHint>maven2</providerHint>
      <localStatus>IN_SERVICE</localStatus>
      <notFoundCacheActive>true</notFoundCacheActive>
      <notFoundCacheTTL>1440</notFoundCacheTTL>
      <userManaged>true</userManaged>
      <exposed>true</exposed>
      <browseable>true</browseable>
      <writePolicy>READ_ONLY</writePolicy>
      <indexable>true</indexable>
      <searchable>true</searchable>
      <localStorage>
        <provider>file</provider>
      </localStorage>
      <remoteStorage>
        <url>http://$PROXY_IP_ADDR:8081/nexus/content/groups/public/</url>
      </remoteStorage>
      <externalConfiguration>
        <repositoryPolicy>RELEASE</repositoryPolicy>
        <checksumPolicy>WARN</checksumPolicy>
        <fileTypeValidation>true</fileTypeValidation>
        <downloadRemoteIndex>true</downloadRemoteIndex>
        <artifactMaxAge>-1</artifactMaxAge>
        <metadataMaxAge>1440</metadataMaxAge>
        <itemMaxAge>1440</itemMaxAge>
        <autoBlockActive>false</autoBlockActive>
      </externalConfiguration>
    </repository>
  </repositories>
  <repositoryGrouping>
    <pathMappings>
      <pathMapping>
        <id>inhouse-stuff</id>
        <groupId>*</groupId>
        <routeType>inclusive</routeType>
        <routePatterns>
          <routePattern>^/(com|org)/somecompany/.*</routePattern>
        </routePatterns>
        <repositories>
          <repository>snapshots</repository>
          <repository>releases</repository>
        </repositories>
      </pathMapping>
      <pathMapping>
        <id>apache-stuff</id>
        <groupId>*</groupId>
        <routeType>exclusive</routeType>
        <routePatterns>
          <routePattern>^/org/some-oss/.*</routePattern>
        </routePatterns>
        <repositories>
          <repository>releases</repository>
          <repository>snapshots</repository>
        </repositories>
      </pathMapping>
    </pathMappings>
  </repositoryGrouping>
  <repositoryTargets>
    <repositoryTarget>
      <id>1</id>
      <name>All (Maven2)</name>
      <contentClass>maven2</contentClass>
      <patterns>
        <pattern>.*</pattern>
      </patterns>
    </repositoryTarget>
    <repositoryTarget>
      <id>2</id>
      <name>All (Maven1)</name>
      <contentClass>maven1</contentClass>
      <patterns>
        <pattern>.*</pattern>
      </patterns>
    </repositoryTarget>
    <repositoryTarget>
      <id>3</id>
      <name>All but sources (Maven2)</name>
      <contentClass>maven2</contentClass>
      <patterns>
        <pattern>(?!.*-sources.*).*</pattern>
      </patterns>
    </repositoryTarget>
    <repositoryTarget>
      <id>4</id>
      <name>All Metadata (Maven2)</name>
      <contentClass>maven2</contentClass>
      <patterns>
        <pattern>.*maven-metadata\.xml.*</pattern>
      </patterns>
    </repositoryTarget>
    <repositoryTarget>
      <id>any</id>
      <name>All (Any Repository)</name>
      <contentClass>any</contentClass>
      <patterns>
        <pattern>.*</pattern>
      </patterns>
    </repositoryTarget>
    <repositoryTarget>
      <id>site</id>
      <name>All (site)</name>
      <contentClass>site</contentClass>
      <patterns>
        <pattern>.*</pattern>
      </patterns>
    </repositoryTarget>
    <repositoryTarget>
      <id>nuget</id>
      <name>All (nuget)</name>
      <contentClass>nuget</contentClass>
      <patterns>
        <pattern>.*</pattern>
      </patterns>
    </repositoryTarget>
  </repositoryTargets>
  <smtpConfiguration>
    <hostname>smtp-host</hostname>
    <port>25</port>
    <username>smtp-username</username>
    <password>{sYfveGhmKlcH8YmZKPsiS1uJQa3aBBqSYQlLhR9T9CU=}</password>
    <systemEmailAddress>system@nexus.org</systemEmailAddress>
  </smtpConfiguration>
  <notification />
</nexusConfiguration>
EOF
}

nexus_start() {
  RUN_AS_USER=root /usr/local/nexus-*/bin/nexus start

  while ! curl -fsm 1 -o /dev/null http://localhost:8081/nexus; do
    sleep 1
  done
}

jenkins_install() {
  rpm -i http://$PROXY_IP_ADDR/jenkins-1.579-1.1.noarch.rpm
  chkconfig jenkins on
}

jenkins_configure_prestart() {
  cat >/var/lib/jenkins/hudson.tasks.Maven.xml <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<hudson.tasks.Maven_-DescriptorImpl>
  <installations>
    <hudson.tasks.Maven_-MavenInstallation>
      <name>Maven</name>
      <home>$(echo /usr/local/apache-maven-*)</home>
      <properties/>
    </hudson.tasks.Maven_-MavenInstallation>
  </installations>
</hudson.tasks.Maven_-DescriptorImpl>
EOF

  mkdir /var/lib/jenkins/updates
  curl -Ls http://updates.jenkins-ci.org/update-center.json | sed -ne 2p >/var/lib/jenkins/updates/default.json

  mkdir /var/lib/jenkins/.m2
  cat >/var/lib/jenkins/.m2/settings.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd" xmlns="http://maven.apache.org/SETTINGS/1.1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <servers>
    <server>
      <username>deployment</username>
      <password>deployment123</password>
      <id>deployment</id>
    </server>
  </servers>
  <mirrors>
    <mirror>
      <mirrorOf>*</mirrorOf>
      <url>http://127.0.0.1:8081/nexus/content/groups/public</url>
      <id>mirror</id>
    </mirror>
  </mirrors>
</settings>
EOF

  chown -R jenkins:jenkins /var/lib/jenkins
}

jenkins_start() {
  service jenkins start

  while ! curl -fsm 1 -o /dev/null http://localhost:8080/; do
    sleep 1
  done
}

jenkins_cli() {
  [ -e /tmp/jenkins-cli.jar ] || curl -so /tmp/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
  java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ "$@"
}

fix_gso
set_tz Europe/London
register_channels rhel-x86_64-server-6
install_packages git java-1.7.0-openjdk-devel

maven_install

register_hostname

nexus_install
nexus_configure
nexus_start

jenkins_install
jenkins_configure_prestart
jenkins_start

jenkins_cli install-plugin git -deploy

jenkins_cli create-job devopsdemo <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<maven2-moduleset plugin="maven-plugin@2.5">
  <actions/>
  <description></description>
  <logRotator class="hudson.tasks.LogRotator">
    <daysToKeep>-1</daysToKeep>
    <numToKeep>10</numToKeep>
    <artifactDaysToKeep>-1</artifactDaysToKeep>
    <artifactNumToKeep>-1</artifactNumToKeep>
  </logRotator>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.2.2">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>$GIT_URL</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers>
    <hudson.triggers.SCMTrigger>
      <spec>*/1 * * * *</spec>
      <ignorePostCommitHooks>false</ignorePostCommitHooks>
    </hudson.triggers.SCMTrigger>
  </triggers>
  <concurrentBuild>false</concurrentBuild>
  <rootModule>
    <groupId>com.redhat.ticketmonster</groupId>
    <artifactId>ticketmonster</artifactId>
  </rootModule>
  <rootPOM>application/pom.xml</rootPOM>
  <goals>clean package</goals>
  <aggregatorStyleBuild>true</aggregatorStyleBuild>
  <incrementalBuild>false</incrementalBuild>
  <ignoreUpstremChanges>false</ignoreUpstremChanges>
  <archivingDisabled>false</archivingDisabled>
  <siteArchivingDisabled>false</siteArchivingDisabled>
  <fingerprintingDisabled>false</fingerprintingDisabled>
  <resolveDependencies>false</resolveDependencies>
  <processPlugins>false</processPlugins>
  <mavenValidationLevel>-1</mavenValidationLevel>
  <runHeadless>false</runHeadless>
  <disableTriggerDownstreamProjects>false</disableTriggerDownstreamProjects>
  <settings class="jenkins.mvn.DefaultSettingsProvider"/>
  <globalSettings class="jenkins.mvn.DefaultGlobalSettingsProvider"/>
  <reporters/>
  <publishers/>
  <buildWrappers/>
  <prebuilders>
    <hudson.tasks.Shell>
      <command>cd application &amp;&amp; mvn versions:set -DnewVersion=0.1-\$BUILD_NUMBER</command>
    </hudson.tasks.Shell>
  </prebuilders>
  <postbuilders>
    <hudson.tasks.Shell>
      <command>cd application &amp;&amp; mvn deploy -DaltDeploymentRepository=deployment::default::http://localhost:8081/nexus/content/repositories/releases/</command>
    </hudson.tasks.Shell>
  </postbuilders>
  <runPostStepsIfResult>
    <name>SUCCESS</name>
    <ordinal>0</ordinal>
    <color>BLUE</color>
    <completeBuild>true</completeBuild>
  </runPostStepsIfResult>
</maven2-moduleset>
EOF

disable_firewall
