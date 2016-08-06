# All of your resources will be prefixed by this name
variable "name" { default = "mantl" }

provider "digitalocean" {
  token = ""
}

module "do-keypair" {
  name = "${var.name}"
  source = "./terraform/digitalocean/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "do-hosts" {
  name = "${var.name}"
  source = "./terraform/digitalocean/hosts"
  ssh_key = "${module.do-keypair.keypair_id}"
  region_name = "nyc3" # this must be a region with metadata support

  control_count = 3
  worker_count = 4
  kubeworker_count = 2
  edge_count = 2
}
