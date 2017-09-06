module Fluent
  class KubernetesTaggedRemoteSyslogOutput < Fluent::Output
    Fluent::Plugin.register_output('kubernetes_tagged_remote_syslog', self)

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

    def shorten_name(str)
      if str.length > 31
        return str.sub(str[23...-6],"..")
      else
        return str
      end
    end

    def emit(tag, es, chain)
      es.each do |_time, record|
        record.each_pair do |_k, v|
          if v.is_a?(String)
            v.force_encoding('utf-8')
          end
        end

        next if skip_namespaces.include?(record.dig('kubernetes', 'namespace_name'))

        @loggers[tag] ||= RemoteSyslogLogger::UdpSender.new(
          @host,
          @port,
          facility: record['facility'] || @facility,
          severity: record['severity'] || @severity,
          program: shorten_name(record.dig('kubernetes', @program) || @program),
          local_hostname: shorten_name(record.dig('kubernetes', @hostname) || @hostname))

        @loggers[tag].transmit((if record.key?('log') then record['log'] else record end).to_s)
      end
      chain.next
    end
  end
end
