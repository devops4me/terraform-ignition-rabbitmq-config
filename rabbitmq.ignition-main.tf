
/*
 | --
 | -- We give both the rabbitmq service unit file and the etcd 3
 | -- unit file for conversion into the machine readable ignition
 | -- json configuration.
 | --
 | -- We declare that the rabbitmq service requires etcd for
 | -- peer discovery in order that systemd brings them both up
 | -- in the correct order on every cluster node.
 | --
*/
data ignition_config rabbitmq
{
    systemd =
    [
        "${data.ignition_systemd_unit.etcd3.id}",
        "${data.ignition_systemd_unit.rabbitmq.id}"
    ]
}


/*
 | --
 | -- This slice of the ignition configuration deals with the
 | -- systemd service. Once rendered it is then placed alongside
 | -- the other ignition configuration blocks in ignition_config
 | --
*/
data ignition_systemd_unit rabbitmq
{
    name = "rabbitmq.service"
    enabled = "true"
    dropin
    {
        name    = "20-clct-rabbitmq.conf"
        content = "${ data.template_file.rabbitmq.rendered }"
    }
}


/*
 | --
 | -- This slice of the ignition configuration deals with the
 | -- systemd service. Once rendered it is then placed alongside
 | -- the other ignition configuration blocks in ignition_config
 | --
*/
data ignition_systemd_unit etcd3
{
    name = "etcd-member.service"
    enabled = "true"
    dropin
    {
        name    = "20-clct-etcd-member.conf"
        content = "${ data.template_file.etcd3.rendered }"
    }
}


/*
 | --
 | -- This is the systemd unit file that ignition will run
 | -- in order to create the RabbitMQ 3.7 queue service.
 | --
 | -- RabbitMQ needs a cookie RABBITMQ_ERLANG_COOKIE in the
 | -- environment variable with a value that is the same for
 | -- every node in the cluster.
 | --
 | -- We ask terraform to generate a random value for this
 | -- cookie and inject it before rendering the template.
 | --
*/
data template_file rabbitmq
{
    template = "${ file( "${path.module}/systemd-rabbitmq.service" ) }"

#### @todo - add the erlang cookie thing here
#### @todo - add the erlang cookie thing here
#### @todo - add the erlang cookie thing here
#### @todo - add the erlang cookie thing here
##### ===>    vars
##### ===>    {
##### ===>        file_discovery_url = "${ data.external.url.result[ "etcd_discovery_url" ] }"
##### ===>    }
}


/*
 | --
 | -- This is the systemd unit file that ignition will run
 | -- in order to create the etcd 3 key-value store.
 | --
 | -- Terraform has to inject just one value which is the
 | -- etcd discovery url that the python script returns.
 | --
*/
data template_file etcd3
{
    template = "${ file( "${path.module}/systemd-etcd.service" ) }"

    vars
    {
        file_discovery_url = "${ data.external.url.result[ "etcd_discovery_url" ] }"
    }
}


/*
 | --
 | -- Run a bash script which only contains a curl command to retrieve
 | -- the etcd discovery url from the service offered by CoreOS.
 | -- This is how to retrieve the URL from any command line.
 | --
 | --     $ curl https://discovery.etcd.io/new?size=3
 | --
*/
data external url
{
    program = [ "python", "${path.module}/etcd-discovery-url.py", "${ var.in_node_count }" ]
}
