resource "alicloud_ecs_key_pair" "publickey" {
  key_pair_name = "${var.first_name}-hashi-key"
  public_key    = file(var.public_key)
}

data "alicloud_images" "images_ds" {
  owners     = "system"
  name_regex = "^ubuntu_.*_x64"
}

data "alicloud_vpcs" "vpcs_ds" {
  name_regex = "^Dev"
}

data "alicloud_vswitches" "default" {
  name_regex = "^APP_AZ"
}

resource "alicloud_security_group" "primary" {
  name                = "${var.first_name}-sg"
  vpc_id              = data.alicloud_vpcs.vpcs_ds.vpcs[0].id
  inner_access_policy = "Accept"
}

resource "alicloud_security_group_rule" "ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.primary.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.primary.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "http_8080" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8080/8080"
  priority          = 1
  security_group_id = alicloud_security_group.primary.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "consul" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8500/8500"
  priority          = 1
  security_group_id = alicloud_security_group.primary.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "nomad" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "4646/4646"
  priority          = 1
  security_group_id = alicloud_security_group.primary.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "vault" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8200/8200"
  priority          = 1
  security_group_id = alicloud_security_group.primary.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "servers" {
  image_id        = data.alicloud_images.images_ds.images.0.id
  instance_name   = "${var.first_name}-${var.server_name_prefix}${format("%02d", count.index + 1)}"
  instance_type   = var.instance_type
  key_name        = alicloud_ecs_key_pair.publickey.id
  security_groups = [alicloud_security_group.primary.id]
  vswitch_id      = data.alicloud_vswitches.default.vswitches[0].id
  count           = var.server_count

  system_disk_category = "cloud_essd"

  tags = {
    Name = "${var.first_name}-${var.server_name_prefix}${format("%02d", count.index + 1)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo adduser --disabled-password --gecos '' ${var.atcomputing_user}",
      "sudo mkdir -p /home/${var.atcomputing_user}/.ssh",
      "sudo touch /home/${var.atcomputing_user}/.ssh/authorized_keys",
      "sudo echo '${file(var.public_key)}' > authorized_keys",
      "sudo mv authorized_keys /home/${var.atcomputing_user}/.ssh",
      "sudo chown -R ${var.atcomputing_user}:${var.atcomputing_user} /home/${var.atcomputing_user}/.ssh",
      "sudo chmod 700 /home/${var.atcomputing_user}/.ssh",
      "sudo chmod 600 /home/${var.atcomputing_user}/.ssh/authorized_keys",
      "sudo usermod -aG sudo ${var.atcomputing_user}",
      "sudo echo '${var.atcomputing_user} ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers.d/90-cloud-init-users",
      "sudo hostnamectl set-hostname ${self.tags.Name}"
    ]

    connection {
      type        = "ssh"
      host        = self.private_ip
      user        = "root"
      private_key = file(var.private_key)
    }
  }
}

resource "alicloud_instance" "clients" {
  image_id        = data.alicloud_images.images_ds.images.0.id
  instance_name   = "${var.first_name}-${var.client_name_prefix}${format("%02d", count.index + 1)}"
  instance_type   = var.instance_type
  key_name        = alicloud_ecs_key_pair.publickey.id
  security_groups = [alicloud_security_group.primary.id]
  vswitch_id      = data.alicloud_vswitches.default.vswitches[0].id
  count           = var.client_count

  system_disk_category = "cloud_essd"

  tags = {
    Name = "${var.first_name}-${var.client_name_prefix}${format("%02d", count.index + 1)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo adduser --disabled-password --gecos '' ${var.atcomputing_user}",
      "sudo mkdir -p /home/${var.atcomputing_user}/.ssh",
      "sudo touch /home/${var.atcomputing_user}/.ssh/authorized_keys",
      "sudo echo '${file(var.public_key)}' > authorized_keys",
      "sudo mv authorized_keys /home/${var.atcomputing_user}/.ssh",
      "sudo chown -R ${var.atcomputing_user}:${var.atcomputing_user} /home/${var.atcomputing_user}/.ssh",
      "sudo chmod 700 /home/${var.atcomputing_user}/.ssh",
      "sudo chmod 600 /home/${var.atcomputing_user}/.ssh/authorized_keys",
      "sudo usermod -aG sudo ${var.atcomputing_user}",
      "sudo echo '${var.atcomputing_user} ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers.d/90-cloud-init-users",
      "sudo hostnamectl set-hostname ${self.tags.Name}"
    ]

    connection {
      type        = "ssh"
      host        = self.private_ip
      user        = "root"
      private_key = file(var.private_key)
    }
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      servers = tomap({
        for instance in alicloud_instance.servers :
        instance.tags.Name => instance.private_ip
      })
      clients = tomap({
        for instance in alicloud_instance.clients :
        instance.tags.Name => instance.private_ip
      })
    }
  )
  filename = "../inventory"
}
