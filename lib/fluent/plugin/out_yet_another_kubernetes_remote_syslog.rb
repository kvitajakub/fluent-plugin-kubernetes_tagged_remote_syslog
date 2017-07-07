module Fluent
  class RemoteSyslogOutput < Fluent::Output
    Fluent::Plugin.register_output('yet_another_kubernetes_remote_syslog', self)

    config_param :host, :string
    config_param :port, :integer, default: 514

    config_param :facility, :string, default: 'user'
    config_param :severity, :string, default: 'notice'
    config_param :program, :string, default: 'pod_name'
    config_param :hostname, :string, default: 'namespace_name'
    config_param :skip_namespaces, :string, default: 'deis kube-system'

    def initialize
      super
      require "remote_syslog_logger"
      @loggers = {}
    end

    def shutdown
      @loggers.values.each(&:close)
      super
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        record.each_pair do |k, v|
          if v.is_a?(String)
            v.force_encoding('utf-8')
          end
        end

        next if !record.key?('kubernetes') ||
                skip_namespaces.include?(record['kubernetes']['namespace_name'])

        @loggers[tag] ||= RemoteSyslogLogger::UdpSender.new(
          @host,
          @port,
          facility: record['facility'] || @facility,
          severity: record['severity'] || @severity,
          program: (record['kubernetes'][@program] || @program)[0...31],
          local_hostname: (record['kubernetes'][@hostname] || @hostname)[0...31])

        @loggers[tag].transmit record['log'].to_s
      end
      chain.next
    end
  end
end
