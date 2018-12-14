
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
    content = "${ data.template_file.rabbitmq.rendered }"
    enabled = "true"
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

    vars
    {
        erlang_cookie = "${ random_string.erlang_cookie.result }"
        rbmq_username = "${ var.in_rmq_username }"
        rbmq_password = "${ random_string.password.result }"
    }
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
 | -- The RabbitMQ user password is generated to contain
 | -- 20 alphanumeric characters and no specials.
 | -- For production this password should be ingested by
 | -- your safe through Terraform's output command.
 | --
*/
resource random_string password
{
    length  = 20
    upper   = true
    lower   = true
    number  = true
    special = false
}


/*
 | --
 | -- To join a cluster RabbitMQ nodes ask each other whether
 | -- their "erlang cookies" match - and they will because the
 | -- value is drawn from the result of this resource.
 | --
 | -- The cookie will hold 24 (and only 24) upper case letters.
 | --
*/
resource random_string erlang_cookie
{
    length  = 24
    upper   = true
    lower   = false
    number  = false
    special = false
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


/*
 | --
 | -- This module dynamically acquires the HVM CoreOS AMI ID for the region that
 | -- this infrastructure is built in (specified by the AWS credentials in play).
 | --
*/
module coreos-ami-id
{
    source = "github.com/devops4me/terraform-aws-coreos-ami-id"
}
