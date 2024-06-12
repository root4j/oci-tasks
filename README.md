# OCI Tasks Demo
Example to deploy in OCI a simple task application made in Java + Angular, with a Postgres database server.

[![Tools](https://skillicons.dev/icons?i=github,linux,java,spring,maven,hibernate,nginx,angular,ts,postgres,terraform,vscode&theme=dark)](https://www.linkedin.com/in/root4j/)

## Execute Terraform Template
[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/root4j/oci-tasks/releases/download/1.0/terraform.zip)

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
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.3-graal
wget https://github.com/root4j/oci-tasks/releases/download/1.0/tasks.jar
wget https://github.com/root4j/oci-tasks/releases/download/1.0/web.zip
chmod +x tasks.jar
unzip web.zip
sudo rm -f /usr/share/nginx/html/*.*
sudo cp -R $HOME/web/* /usr/share/nginx/html
sudo sed -i "s|http://localhost:8080/|http://$(curl -s ipinfo.io/ip):8080/|g" /usr/share/nginx/html/main-AJTMVIE2.js
mkdir -p $HOME/.config/systemd/user
cat << EOF > $HOME/.config/systemd/user/task-api.service
[Unit]
Description=Spring Boot Task API Service

[Service]
ExecStart=$HOME/.sdkman/candidates/java/current/bin/java -jar /home/opc/tasks.jar --my.server.name=db.pub.task.oraclevcn.com

[Install] 
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now task-api
systemctl --user start task-api
systemctl --user status task-api
journalctl -t task-api
```