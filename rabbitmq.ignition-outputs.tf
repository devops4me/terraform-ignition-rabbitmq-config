
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
