
################ ############################################################## ########
################ Module [[[etcd ignition configuration]]] Input Variables List. ########
################ ############################################################## ########


### ########################## ###
### [[variable]] in_node_count ###
### ########################## ###

variable in_node_count
{
    description = "The instance (node) count for the initial cluster which defaults to four (4)."
    default     = "4"
}
