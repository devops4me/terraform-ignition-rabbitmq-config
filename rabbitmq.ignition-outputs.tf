
################ ########################################################################### ########
################ Module [[[rabbitmq service ignition configuration]]] Output Variables List. ########
################ ########################################################################### ########


### ############################## ###
### [[output]] out_ignition_config ###
### ############################## ###

output out_ignition_config
{
    value = "${ data.ignition_config.rabbitmq.rendered }"
}


### ########################### ###
### [[output]] out_rmq_password ###
### ########################### ###

output out_rmq_password
{
    value = "${ random_string.password.result }"
}


### ##################### ###
### [[output]] out_ami_id ###
### ##################### ###

output out_ami_id
{
    value = "${ module.coreos-ami-id.out_ami_id }"
}
