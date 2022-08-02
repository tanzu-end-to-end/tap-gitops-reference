# Create Tanzu Mission Control attach cluster entry
resource "tanzu-mission-control_cluster" "tap_cluster" {

  for_each = toset(var.clusters[*].name)

  management_cluster_name = "attached"
  provisioner_name        = "attached"
  name                    = each.key


  spec {
    cluster_group = var.cluster_group
  }

  //Dodd mentioned some issues with clean deletions.  Not
  //sure if this help but giving a try
  depends_on = [
    module.eks["tap-view"],
    module.eks["tap-iterate"]

  ]

}


