# fluent-plugin-kubernetes_tagged_remote_syslog

<!-- [![Build Status](https://travis-ci.org/kvitajakub/fluent-plugin-kubernetes_tagged_remote_syslog.svg?branch=master)](https://travis-ci.org/kvitajakub/fluent-plugin-kubernetes_tagged_remote_syslog) -->

[Fluentd](http://fluentd.org) plugin for output to remote syslog service (e.g. [Papertrail](http://papertrailapp.com/)). It is meant to use in Kubernetes environment with [kubernetes_metadata_filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) plugin annotating the messages.

This plugin was created because regular remote syslog Fluentd plugins doesn't work well with kubernetes annotated messages. `hostname`/`program` fields have not helpful values `localhost`/`fluentd` and actual message is unreadable compact JSON.

## Installation

```bash
 fluent-gem install fluent-plugin-kubernetes_tagged_remote_syslog
```

## Example input/output
Default input should be JSON message annotated with kubernetes info:
```
{
  "log": "2015/05/05 19:54:41 log me\n",
  "stream": "stderr",
  "docker": {
    "id": "df14e0d5ae4c07284fa636d739c8fc2e6b52bc344658de7d3f08c36a2e804115",
  }
  "kubernetes": {
    "host": "jimmi-redhat.localnet",
    "pod_name":"fabric8-console-controller-98rqc",
    "pod_id": "c76927af-f563-11e4-b32d-54ee7527188d",
    "container_name": "fabric8-console-container",
    "namespace_name": "default",
    "namespace_id": "23437884-8e08-4d95-850b-e94378c9b2fd",
    "labels": {
      "component": "fabric8Console"
    }
  }
}
```
This will become:
```
default fabric8-console-controller-98rqc: 2015/05/05 19:54:41 \n
```

And at the message receive Papertrail will add a timestamp in front of the message:
```
May 05 19:54:45 default fabric8-console-controller-98rqc: 2015/05/05 19:54:41 log me\n
```

## Usage
```
<match foo>
  type kubernetes_tagged_remote_syslog
  host example.com
  port 514
  program 'pod_name'
  hostname 'namespace_name'
</match>
```
`hostname` value will look for the key with that name in message and adds it as hostname. If no key is found it will use the value of the key itself.
`program` value works in the same way as `hostname`.

## Dropping messages from namespaces you don't need
Parameter `skip_namespaces` will drop messages from selected namespaces. This should be technically in its own filter plugin, but that would require installing and configuring two pluggins so I just dropped it here.

Default configuration will drop messages from `kube-system` and `deis` namespaces.

## Special Use Case - Deis Workflow

I am running this plugin myself as part of [Deis Workflow Fluentd](https://github.com/deis/fluentd) DaemonSet. This requires editing `values.yaml`:
```
...
fluentd:
  syslog:
    # Configure the following ONLY if using Fluentd to send log messages to both
    # the Logger component and external syslog endpoint
    # external syslog endpoint url
    host: ""
    # external syslog endpoint port
    port: ""
  daemon_environment:
    FLUENTD_PLUGIN_1: "fluent-plugin-kubernetes_tagged_remote_syslog"
    CUSTOM_STORE_1: "<store> \n
                       @type kubernetes_tagged_remote_syslog \n
                       host logs5.papertrailapp.com \n
                       port REDACTED \n
                     </store>"
...
```
Plugin will be installed with `fluent-gem` from [rubygems.com](https://rubygems.org/).

## License

Copyright (c) 2017 Jakub Kvita. See LICENSE for details.
