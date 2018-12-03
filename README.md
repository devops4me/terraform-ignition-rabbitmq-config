
# etcd | ignition systemd unit configuration

This module **converts human manageable systemd unit files** into **machine readable container linux ignition json** that will configure each node of the etcd cluster.

---

### etcd systemd unit file

```ini
[Unit]
Description=Sets up the inbuilt CoreOS etcd 3 key value store
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
EnvironmentFile=/run/metadata/coreos
ExecStart=/usr/lib/coreos/etcd-wrapper $ETCD_OPTS \
  --listen-peer-urls="http://$${COREOS_EC2_IPV4_LOCAL}:2380" \
  --listen-client-urls="http://0.0.0.0:2379" \
  --initial-advertise-peer-urls="http://$${COREOS_EC2_IPV4_LOCAL}:2380" \
  --advertise-client-urls="http://$${COREOS_EC2_IPV4_LOCAL}:2379" \
  --discovery="${file_discovery_url}"
```

---

## Architectural Placement

Academically this module belongs in the innermost layer of a cluster and is the only layer that knows which services the cluster profers. This layer is responsible for telling

- the cluster config layer which AMI to use
- the cluster config layer which ignition configuration (userdata) to bootstrap each node with
- the network layer which ports traffic is allowed to flow through
- the network layer which load balancer listeners should be configured

There are **no Terraform resource statements** in this module and you'd expect that from something that solely provides node services configuration. It is completely separate both from infrastructure and or network components.

---

## Usage

Copy this into a file and then run **`terraform init`** and **`terraform apply -auto-approve`** and out comes the ignition config.

```hcl
module etcd-ignition-config
{
    source        = "github.com/devops4me/terraform-ignition-etcd-config"
    in_node_count = 6
}

output etcd_ignition_config
{
    value = "${ module.etcd-ignition-config.out_ignition_config }"
}
```

Your node is configured when you feed the output into the user data field of either an EC2 instance (**[fixed size cluster](https://github.com/devops4me/terraform-aws-ec2-cluster-fixed-size)**) or a launch configuration (**[auto-scaling cluster](https://github.com/devops4me/terraform-aws-ec2-cluster-auto-scale)**).

## Module Inputs

## Module Outputs

---

## Ignition User Data Input Example

Ignition config is in JSON format and is not designed to be human readable. This example demonstrates how the terraform ignition provider reads the systemd unit files and then **transpiles it** to the JSON code below which is passed into the **user data input variable** in this module.

### The Transpiled Ignition Configuration

```json
{
   "ignition":{
      "config":{

      },
      "timeouts":{

      },
      "version":"2.1.0"
   },
   "networkd":{

   },
   "passwd":{

   },
   "storage":{

   },
   "systemd":{
      "units":[
         {
            "dropins":[
               {
                  "contents":"[Unit]\nDescription=Sets up the inbuilt CoreOS etcd 3 key value store\nRequires=coreos-metadata.service\nAfter=coreos-metadata.service\n\n[Service]\nEnvironmentFile=/run/metadata/coreos\nExecStart=\nExecStart=/usr/lib/coreos/etcd-wrapper $ETCD_OPTS \\\n  --listen-peer-urls=\"http://${COREOS_EC2_IPV4_LOCAL}:2380\" \\\n  --listen-client-urls=\"http://0.0.0.0:2379\" \\\n  --initial-advertise-peer-urls=\"http://${COREOS_EC2_IPV4_LOCAL}:2380\" \\\n  --advertise-client-urls=\"http://${COREOS_EC2_IPV4_LOCAL}:2379\" \\\n  --discovery=\"https://discovery.etcd.io/93d2817eddad15fe6ba844e292e5c11a\"\n",
                  "name":"20-clct-etcd-member.conf"
               }
            ],
            "enabled":true,
            "name":"etcd-member.service"
         }
      ]
   }
}
```


---

## 0 Resources is Expected

Seeing **zero resources can be slightly concerning** until we remember that this module solely provides node services configuration. It is **completely separate** both from infrastructure and network components.

    data.external.url: Refreshing state...
    data.external.url: Refreshing state...
    data.template_file.service: Refreshing state...
    data.ignition_systemd_unit.etcd3: Refreshing state...
    data.ignition_config.etcd3: Refreshing state...
    data.template_file.service: Refreshing state...
    data.ignition_systemd_unit.etcd3: Refreshing state...
    data.ignition_config.etcd3: Refreshing state...

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.


## Terraform Ignition Provider

This module is not named **`terraform-aws-...`** because it does not use the AWS provider. Thankfully **no IAM user credentials** need to be provided.

Terraform tells you that it is using

- the **external provider** to run the etcd cluster discovery url script
- the **ignition provider** to convert the service unit files to ignition json config and
- the **template provider** to read the unit file and perform the variable interpolation

```
* provider.external: version = "~> 1.0"
* provider.ignition: version = "~> 1.0"
* provider.template: version = "~> 1.0"
```

---

Okay - new readme

${file("etcd3-systemd.service")}

-------------------------------------------------
Every node runs this rabbitmq start command.
-------------------------------------------------

docker run -d --name rabbitmq --network host --restart=on-failure:7 --env RABBITMQ_ERLANG_COOKIE="ABCDEFGHIJ" devops4me/rabbitmq-3.7


Removed the -d (daemon)
docker run --name rabbitmq --network host --restart=on-failure:5 --env RABBITMQ_ERLANG_COOKIE="ABCDEFGHIJ" devops4me/rabbitmq-3.7


wget https://raw.githubusercontent.com/devops4me/terraform-aws-rabbitmq-3.7-cluster/master/docker.rabbitmq.service

sudo cp docker.rabbitmq.service /etc/systemd/system/docker.rabbitmq.service
sudo systemctl start docker.rabbitmq


journalctl --unit docker.rabbitmq.service
systemctl cat docker.rabbitmq
docker logs -f rabbitmq


systemctl status docker.rabbitmq

@todo - get terraform to automatically add the erlang cookie

-------------------------------------------------
Every node needs to remote the guest guest user. But ...
-------------------------------------------------

-------------------------------------------------
... but the rabbitmq user need be created only on the first node.
-------------------------------------------------

docker exec --interactive --tty rabbitmq bash -c "rabbitmqctl add_user test test"
docker exec --interactive --tty rabbitmq bash -c "rabbitmqctl set_user_tags test administrator"
docker exec --interactive --tty rabbitmq bash -c 'rabbitmqctl set_permissions -p / test ".*" ".*" ".*"'




--------------------------------------------------------------
Look for config transpiler to engineer and reverse engineer
--------------------------------------------------------------



-------------------------------------------------
Think abou the below ports
-------------------------------------------------


    4369: epmd, a peer discovery service used by RabbitMQ nodes and CLI tools
    5672, 5671: used by AMQP 0-9-1 and 1.0 clients without and with TLS
    25672: used for inter-node and CLI tools communication (Erlang distribution server port) and is allocated from a dynamic range (limited to a single port by default, computed as AMQP port + 20000). Unless external connections on these ports are really necessary (e.g. the cluster uses federation or CLI tools are used on machines outside the subnet), these ports should not be publicly exposed. See networking guide for details.
    35672-35682: used by CLI tools (Erlang distribution client ports) for communication with nodes and is allocated from a dynamic range (computed as server distribution port + 10000 through server distribution port + 10010). See networking guide for details.
    15672: HTTP API clients, management UI and rabbitmqadmin (only if the management plugin is enabled)
    61613, 61614: STOMP clients without and with TLS (only if the STOMP plugin is enabled)
    1883, 8883: (MQTT clients without and with TLS, if the MQTT plugin is enabled
    15674: STOMP-over-WebSockets clients (only if the Web STOMP plugin is enabled)
    15675: MQTT-over-WebSockets clients (only if the Web MQTT plugin is enabled)






# RabbitMQ 3.7 Cluster with CoreOS ETCD Discovery | Terraform | Ignition

This terraform module uses **ignition** to bring up an **etcd3 cluster** on **CoreOS** in the AWS cloud. It returns you a **single (application) load balancer url** making the cluster accessible for reading, writing and querying using CUrl or a REST API.

Use the Route53 module to put the load balancer Url behind a human readable DNS name.

Usage

    module etcd3_cluster
    {
        source                 = "github.com/devops4me/terraform-aws-etcd3-cluster"
        in_vpc_cidr            = "10.99.0.0/16"
        in_ecosystem           = "etcd3-cluster"
    }

    output etcd3_cluster_url
    {
        value = "${ module.etcd3_cluster.out_etcd3_cluster_url }"
    }

    output etcd3_discovery_url
    {
        value = "${ module.etcd3_cluster.out_etcd3_discovery_url }"
    }

Ignition replaces the legacy cloud init (cloud-config.yaml) as a means of boostrapping CoreOS hence this module uses the **terraform ignition resource** to configure the cluster as the machines come up.

**In only 20 seconds Terraform and Ignition can bring up a 5 node etcd3 cluster inside the AWS cloud.**


## etcd cluster load balancer url

This module places a load balancer in front of the etcd node cluster and provides it as an output. Use CUrl or the etcd REST API through this load balancer URL to converse with the cluster.

    http://applb-etcd3-cluster-xxxxxxxxxx.eu-west-2.elb.amazonaws.com/v2/stats/leader

**To prove this visit the path /v2/stats/leader and keep clicking refresh.**

A third of the time the request will land on the leader's node and two-thirds of the time it won't.

```json
{
   "leader":"57b0110512623df",
   "followers":{
      "2c455da15ca7bea1":{
         "latency":{
            "current":0.001424,
            "average":0.0021979213747645955,
            "standardDeviation":0.002590615376169443,
            "minimum":0.001039,
            "maximum":0.045671
         },
         "counts":{
            "fail":0,
            "success":4248
         }
      },
      "60f9b51c7aecae3d":{
         "latency":{
            "current":0.00116,
            "average":0.00239927976470589,
            "standardDeviation":0.002361182466594901,
            "minimum":0.001031,
            "maximum":0.039685
         },
         "counts":{
            "fail":0,
            "success":4250
         }
      }
   }
}
```

---

## etcd url locations

Note that we can use the individual host urls or the single cluster load balancer url. As we've mapped the backend target port 2379 to the front-end listener port 80 we can use the load balancer url in the same way we would use any web url.

    http://<<host-url>>:2379/health
    http://<<host-url>>:2379/version

    http://<<load-balancer-url>>/health
    http://<<load-balancer-url>>/version

    $ curl http://<<load-balancer-url>>/v2/keys/planets -XPUT -d value="earth jupiter mars"
    $ curl http://<<load-balancer-url>>/v2/keys/galaxies -XPUT -d value="milky way / Orion"

    $ curl http://<<load-balancer-url>>/v2/keys/planets
    $ curl http://<<load-balancer-url>>/v2/keys/galaxies

The response to the queries after setting the data should be something like this.

    {
       "action":"get",
       "node":{
          "key":"/planets",
          "value":"earth jupiter mars",
          "modifiedIndex":8,
          "createdIndex":8
       }
    }

Data can be modified and deleted with the below API calls.

    $ curl http://<<load-balancer-url>>/v2/keys/planets -XPUT -d value="mercury/venus/saturn/jupiter/earth"

    {
       "action":"set",
       "node":{
          "key":"/planets",
          "value":"mercury/venus/saturn/jupiter/earth",
          "modifiedIndex":10,
          "createdIndex":10
       },
       "prevNode":{
          "key":"/planets",
          "value":"earth jupiter mars",
          "modifiedIndex":8,
          "createdIndex":8
       }
    }

    $ curl http://<<load-balancer-url>>/v2/keys/planets -XDELETE

    {
       "action":"delete",
       "node":{
          "key":"/planets",
          "modifiedIndex":11,
          "createdIndex":10
       },
       "prevNode":{
          "key":"/planets",
          "value":"mercury/venus/saturn/jupiter/earth",
          "modifiedIndex":10,
          "createdIndex":10
       }
    }


## etcd discovery url | python script

Every etcd cluster instance must have a unique discovery url. The discovery url is a service that the nodes contact as they are booting up and it helps them decide who is the leader and also to gain information about the available peers.

In this module Terraform calls a small python script which gets a fresh discovery url every time a new cluster is brought up. The python script takes one parameter which is the number of nodes the cluster contains.

### python script logs | discovery url

After a successful run visit file **`etcd3-discovery-url.log`** and the discovery url will be on the last line within square brackets.

    20181118 06:29:37 PM [etcd3-discovery-url.py] invoking script to grab an etcd discovery url.
    20181118 06:29:37 PM The stated node count in the etcd cluster is [3]
    20181118 06:29:37 PM Starting new HTTPS connection (1): discovery.etcd.io:443
    20181118 06:29:38 PM https://discovery.etcd.io:443 "GET /new?size=3 HTTP/1.1" 200 58
    20181118 06:29:38 PM The etcd discovery url retrieved is [https://discovery.etcd.io/9a69d64726338dabf0a279d4fa7e803e]

Visit the discovery url and the resultant JSON should be like the below.

#### Discovery URL JSON

Note that the JSON returned (when pretty-fied) shows the private IP addresses of the ec2 nodes as per the ignition script.

{
   "action":"get",
   "node":{
      "key":"/_etcd/registry/9a69d64726338dabf0a279d4fa7e803e",
      "dir":true,
      "nodes":[
         {
            "key":"/_etcd/registry/9a69d64726338dabf0a279d4fa7e803e/38cebe7031d3d519",
            "value":"741452a8c5544c7b9d93339dd98d3870=http://10.66.44.247:2380",
            "modifiedIndex":1509771734,
            "createdIndex":1509771734
         },
         {
            "key":"/_etcd/registry/9a69d64726338dabf0a279d4fa7e803e/968d216a6ef51a51",
            "value":"9a011e178ed544cd8e23d46a0c1d23c4=http://10.66.25.217:2380",
            "modifiedIndex":1509771735,
            "createdIndex":1509771735
         },
         {
            "key":"/_etcd/registry/9a69d64726338dabf0a279d4fa7e803e/39beec7eb77a8a4",
            "value":"8f0e7d5107f947d0b1ba5e6485af1c01=http://10.66.11.142:2380",
            "modifiedIndex":1509771771,
            "createdIndex":1509771771
         }
      ],
      "modifiedIndex":1509771563,
      "createdIndex":1509771563
   }
}


## Consider Node Removal and Setting HA Policy to mirror data and queues

AUTOCLUSTER_CLEANUP to true removes the node automatically, if AUTOCLUSTER_CLEANUP is false you need to remove the node manually.

Scaling down and AUTOCLUSTER_CLEANUP can be very dangerous, if there are not HA policies all the queues and messages stored to the node will be lost. To enable HA policy you can use the command line or the HTTP API, in this case the easier way is the HTTP API, as:

    curl -u guest:guest  -H "Content-Type: application/json" -X PUT \
    -d '{"pattern":"","definition":{"ha-mode":"exactly","ha-params":3,"ha-sync-mode":"automatic"}}' \
    http://172.17.8.101:15672/api/policies/%2f/ha-3-nodes

Note: Enabling the mirror queues across all the nodes could impact the performance, especially when the number of the nodes is undefined. Using "ha-mode":"exactly","ha-params":3 we enable the mirror only for 3 nodes. So scaling down should be done for one node at time, in this way RabbitMQ can move the mirroring to other nodes.



## RabbitMQ and Port Access | Security Groups

### How to Discover what RabbitMQ is listening to (and from where)

rabbitmqctl uses Erlang Distributed Protocol (EDP) to communicate with RabbitMQ. Port 5672 provides AMQP protocol. You can investigate EDP port that your RabbitMQ instance uses:

---

    $ netstat -uptan | grep beam
    tcp        0      0 0.0.0.0:55950           0.0.0.0:*               LISTEN      31446/beam.smp  
    tcp        0      0 0.0.0.0:15672           0.0.0.0:*               LISTEN      31446/beam.smp  
    tcp        0      0 0.0.0.0:55672           0.0.0.0:*               LISTEN      31446/beam.smp  
    tcp        0      0 127.0.0.1:55096         127.0.0.1:4369          ESTABLISHED 31446/beam.smp  
    tcp6       0      0 :::5672                 :::*                    LISTEN      31446/beam.smp  

---

It means that RabbitMQ:

    connected to EPMD (Erlang Port Mapper Daemon) on 127.0.0.1:4369 to make nodes able to see each other
    waits for incoming EDP connection on port 55950
    waits for AMQP connection on port 5672 and 55672
    waits for incoming HTTP management connection on port 15672

To make rabbitmqctl able to connect to RabbitMQ you also have to forward port 55950 and allow RabbitMQ instance connect to 127.0.0.1:4369. It is possible that RabbitMQ EDP port is dinamic, so to make it static you can try to use ERL_EPMD_PORT variable of Erlang environment variables or use inet_dist_listen_min and inet_dist_listen_max of Erlang Kernel configuration options and apply it with RabbitMQ environment variable - export RABBITMQ_CONFIG_FILE="/path/to/my_rabbitmq.conf

---

@todo In a table state which ports will potentially carry external traffic (load balancer included).

---

RabbitMQ nodes bind to ports (open server TCP sockets) in order to accept client and CLI tool connections. Other processes and tools such as SELinux may prevent RabbitMQ from binding to a port. When that happens, the node will fail to start. CLI tools, client libraries and RabbitMQ nodes also open connections (client TCP sockets). Firewalls can prevent nodes and CLI tools from communicating with each other. Make sure the following ports are accessible:

    4369: epmd, a peer discovery service used by RabbitMQ nodes and CLI tools
    5672, 5671: used by AMQP 0-9-1 and 1.0 clients without and with TLS
    25672: used for inter-node and CLI tools communication (Erlang distribution server port) and is allocated from a dynamic range (limited to a single port by default, computed as AMQP port + 20000). Unless external connections on these ports are really necessary (e.g. the cluster uses federation or CLI tools are used on machines outside the subnet), these ports should not be publicly exposed. See networking guide for details.
    35672-35682: used by CLI tools (Erlang distribution client ports) for communication with nodes and is allocated from a dynamic range (computed as server distribution port + 10000 through server distribution port + 10010). See networking guide for details.
    15672: HTTP API clients, management UI and rabbitmqadmin (only if the management plugin is enabled)
    61613, 61614: STOMP clients without and with TLS (only if the STOMP plugin is enabled)
    1883, 8883: (MQTT clients without and with TLS, if the MQTT plugin is enabled
    15674: STOMP-over-WebSockets clients (only if the Web STOMP plugin is enabled)
    15675: MQTT-over-WebSockets clients (only if the Web MQTT plugin is enabled)
