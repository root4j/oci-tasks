# +--------------------------+
# | Declaration of Variables |
# +--------------------------+
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "network_cidr" {}
variable "ssh_key_public" {}
variable "ssh_key_private" {}
variable "shape" {}
variable "shape_cpu" {}
variable "shape_memory" {}
variable "shape_disk" {}
# +--------------------+
# | Provider Selection |
# +--------------------+
provider "oci" {
    tenancy_ocid = var.tenancy_ocid
    region       = var.region
}
# +--------------+
# | Data Sources |
# +--------------+
data "oci_identity_availability_domains" "rad" {
	compartment_id = var.compartment_ocid
}

data "oci_core_images" "shape_oracle_linux" {
	compartment_id           = var.compartment_ocid
	operating_system         = "Oracle Linux"
    shape                    = var.shape
	operating_system_version = "8"
	sort_by                  = "TIMECREATED"
	sort_order               = "DESC"
}
# +-------------------------+
# | Creation of the Network |
# +-------------------------+
resource "oci_core_vcn" "my_vcn" {
	compartment_id = var.compartment_ocid
	cidr_block     = "${var.network_cidr}.0.0/16"
	display_name   = "My VCN"
	dns_label      = "task"
}

resource "oci_core_internet_gateway" "my_internet_gateway" {
    compartment_id = var.compartment_ocid
	display_name   = "My Internet Gateway"
	enabled        = "true"
	vcn_id         = oci_core_vcn.my_vcn.id
}

resource "oci_core_default_route_table" "route_table_public" {
    manage_default_resource_id = oci_core_vcn.my_vcn.default_route_table_id
	compartment_id             = var.compartment_ocid
	display_name               = "My Public Route Table"

	route_rules {
		destination       = "0.0.0.0/0"
		destination_type  = "CIDR_BLOCK"
		network_entity_id = oci_core_internet_gateway.my_internet_gateway.id
	}
}

resource "oci_core_default_security_list" "security_list_public" {
	manage_default_resource_id = oci_core_vcn.my_vcn.default_security_list_id
	compartment_id             = var.compartment_ocid
	display_name               = "My Public Security List"

	egress_security_rules {
		destination      = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol         = "all"
		stateless        = "false"
	}

	ingress_security_rules {
		protocol    = "all"
		source      = "${var.network_cidr}.0.0/16"
		source_type = "CIDR_BLOCK"
		stateless   = "false"
	}

	ingress_security_rules {
		protocol    = "6"
		source      = "0.0.0.0/0"
		source_type = "CIDR_BLOCK"
		stateless   = "false"
		tcp_options {
			max = "22"
			min = "22"
		}
	}
}

resource "oci_core_subnet" "my_public_subnet" {
	cidr_block          = "${var.network_cidr}.0.0/24"
	display_name        = "My Public Subnet"
	dns_label           = "pub"
	security_list_ids   = [oci_core_vcn.my_vcn.default_security_list_id]
	compartment_id      = var.compartment_ocid
	vcn_id              = oci_core_vcn.my_vcn.id
	route_table_id      = oci_core_vcn.my_vcn.default_route_table_id
}

resource "oci_core_network_security_group" "my_nsg_db_srv" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.my_vcn.id
    display_name   = "My NSG DB Server"
}

resource "oci_core_network_security_group_security_rule" "my_nsg_db_srv_rule_001" {
    network_security_group_id = oci_core_network_security_group.my_nsg_db_srv.id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    stateless                 = "false"
    tcp_options {
        destination_port_range {
            max = "5432"
            min = "5432"
        }
    }
}

resource "oci_core_network_security_group" "my_nsg_app_srv" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_vcn.my_vcn.id
    display_name   = "My NSG App Server"
}

resource "oci_core_network_security_group_security_rule" "my_nsg_app_srv_rule_001" {
    network_security_group_id = oci_core_network_security_group.my_nsg_app_srv.id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    stateless                 = "false"
    tcp_options {
        destination_port_range {
            max = "80"
            min = "80"
        }
    }
}

resource "oci_core_network_security_group_security_rule" "my_nsg_app_srv_rule_002" {
    network_security_group_id = oci_core_network_security_group.my_nsg_app_srv.id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    stateless                 = "false"
    tcp_options {
        destination_port_range {
            max = "8080"
            min = "8080"
        }
    }
}
# +-----------------+
# | Local Variables |
# +-----------------+
locals {
	all_images = data.oci_core_images.shape_oracle_linux.images
	compartment_images = [for image in local.all_images : image.id if length(regexall("Oracle-Linux-[0-9].[0-9]-20[0-9]*",image.display_name)) > 0 ]
}
# +-----------+
# | Instances |
# +-----------+
resource "oci_core_instance" "db_srv" {
    availability_domain = data.oci_identity_availability_domains.rad.availability_domains.0.name
    compartment_id      = var.compartment_ocid
    display_name        = "db"
    fault_domain        = "FAULT-DOMAIN-1"

	shape               = var.shape
	shape_config {
		memory_in_gbs = var.shape_memory
		ocpus         = var.shape_cpu
	}

    metadata = {
        ssh_authorized_keys = var.ssh_key_public 
    }

    create_vnic_details {
        subnet_id                 = oci_core_subnet.my_public_subnet.id
        display_name              = "primaryvnic"
        assign_public_ip          = true
        assign_private_dns_record = true
		nsg_ids                   = [oci_core_network_security_group.my_nsg_db_srv.id]
        hostname_label            = "db"
    }

    source_details {
        source_type             = "image"
        source_id               = local.all_images.0.id
        boot_volume_size_in_gbs = var.shape_disk
    }
}

resource "oci_core_instance" "app_srv" {
    availability_domain = data.oci_identity_availability_domains.rad.availability_domains.0.name
    compartment_id      = var.compartment_ocid
    display_name        = "app"
    fault_domain        = "FAULT-DOMAIN-1"

	shape               = var.shape
	shape_config {
		memory_in_gbs = var.shape_memory
		ocpus         = var.shape_cpu
	}

    metadata = {
        ssh_authorized_keys = var.ssh_key_public 
    }

    create_vnic_details {
        subnet_id                 = oci_core_subnet.my_public_subnet.id
        display_name              = "primaryvnic"
        assign_public_ip          = true
        assign_private_dns_record = true
		nsg_ids                   = [oci_core_network_security_group.my_nsg_app_srv.id]
        hostname_label            = "app"
    }

    source_details {
        source_type             = "image"
        source_id               = local.all_images.0.id
        boot_volume_size_in_gbs = var.shape_disk
    }
}
# +------------------+
# | Remote Execution |
# +------------------+
resource "null_resource" "remote_exec_db_srv" {
    depends_on = [oci_core_instance.db_srv]

    provisioner "remote-exec" {
        connection {
            agent       = false
            timeout     = "10m"
            host        = oci_core_instance.db_srv.public_ip
            user        = "opc"
            private_key = base64decode(var.ssh_key_private)
        }

        inline = [
			"sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm",
			"sudo dnf -qy module disable postgresql",
			"sudo dnf install -y postgresql15-server",
			"sudo /usr/pgsql-15/bin/postgresql-15-setup initdb",
			"sudo systemctl enable postgresql-15",
			"sudo systemctl start postgresql-15",
			"sudo firewall-cmd --zone=public --add-port=22/tcp --permanent",
			"sudo firewall-cmd --zone=public --add-port=5432/tcp --permanent",
			"sudo firewall-cmd --reload",
			"sudo -u postgres psql --command=\"CREATE USER task_user WITH CREATEDB CREATEROLE PASSWORD '0cI_TaSk_D3m0--';\"",
			"sudo -u postgres psql --command=\"CREATE DATABASE task_db OWNER task_user;\"",
        ]
    }
}

resource "null_resource" "remote_exec_app_srv" {
    depends_on = [oci_core_instance.db_srv, null_resource.remote_exec_db_srv, oci_core_instance.app_srv]

    provisioner "remote-exec" {
        connection {
            agent       = false
            timeout     = "10m"
            host        = oci_core_instance.app_srv.public_ip
            user        = "opc"
            private_key = base64decode(var.ssh_key_private)
        }

        inline = [
            "sudo dnf install java-21-openjdk httpd -y",
            "sudo systemctl enable --now httpd.service",
            "sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent",
            "sudo firewall-cmd --zone=public --add-port=80/tcp --permanent",
            "sudo firewall-cmd --zone=public --add-port=22/tcp --permanent",
            "sudo firewall-cmd --reload",
            "sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat",
            "wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.30/bin/apache-tomcat-10.1.30.tar.gz -O /tmp/tomcat-10.tar.gz",
            "sudo -u tomcat tar -xzvf /tmp/tomcat-10.tar.gz --strip-components=1 -C /opt/tomcat",
            "wget https://github.com/root4j/oci-tasks/releases/download/2.0/tasks.war",
            "wget https://github.com/root4j/oci-tasks/releases/download/2.0/web.zip",
            "unzip web.zip",
            "sudo rm -f /var/www/html/*.*",
            "sudo cp -R $HOME/web/* /var/www/html",
            "sudo sed -i \"s|http://localhost:8080/|http://$(curl -s ipinfo.io/ip):8080/tasks/|g\" /var/www/html/main-5MHLNSMR.js",
        ]
    }
}
# +-------------------+
# | Outputs Variables |
# +-------------------+
output "db_srv_public_ip" {
    value = oci_core_instance.db_srv.public_ip
}

output "app_srv_public_ip" {
    value = oci_core_instance.app_srv.public_ip
}