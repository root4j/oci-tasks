# OCI Tasks Demo
Example to deploy in OCI a simple task application made in Java + Angular, with a Postgres database server.

[![Tools](https://skillicons.dev/icons?i=github,linux,java,spring,maven,hibernate,angular,ts,postgres,terraform,vscode&theme=dark)](https://www.linkedin.com/in/root4j/)

## Execute Terraform Template
[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/root4j/oci-tasks/releases/download/1.0/Tasks.zip)

## Execute Script in db VM
```bash
sudo sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|g" /var/lib/pgsql/15/data/postgresql.conf
sudo su postgres
cat >> /var/lib/pgsql/15/data/pg_hba.conf << EOF
# specify network range you allow to connect on [ADDRESS] section
host    all             all             0.0.0.0/0             scram-sha-256
EOF
exit
sudo systemctl restart postgresql-15
sudo systemctl status postgresql-15
```

## Execute Script in app VM
```bash
sudo -su root
cp /home/opc/tasks.war /opt/tomcat/webapps/
cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

ExecReload=/bin/kill $MAINPID
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now tomcat
systemctl status tomcat
exit
```