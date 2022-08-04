output "tmc_execution_commands" {
  value = {
    # the execution_cmd is only present in the output in the beginning.  So must test for existance
    for k, v in tanzu-mission-control_cluster.tap_cluster : k => lookup(v.status, "execution_cmd", "missing")
  }
}