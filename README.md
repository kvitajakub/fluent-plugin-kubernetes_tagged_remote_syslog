# fluent-plugin-kubernetes_tagged_remote_syslog

<!-- [![Build Status](https://travis-ci.org/dlackty/fluent-plugin-remote_syslog.svg?branch=master)](https://travis-ci.org/dlackty/fluent-plugin-remote_syslog) -->

[Fluentd](http://fluentd.org) plugin for output to remote syslog service (e.g. [Papertrail](http://papertrailapp.com/)). It is meant to use in Kubernetes environment with [kubernetes_metadata_filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) plugin annotating the messages.

## Installation

```bash
 fluent-gem install fluent-plugin-kubernetes_tagged_remote_syslog
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

## License

Copyright (c) 2017 Jakub Kvita. See LICENSE for details.
