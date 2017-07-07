require "test_helper"
require "fluent/plugin/out_kubernetes_tagged_remote_syslog"

class KubernetesTaggedRemoteSyslogOutputTest < MiniTest::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG, tag = "test.kubernetes_tagged_remote_syslog")
    Fluent::Test::OutputTestDriver.new(Fluent::KubernetesTaggedRemoteSyslogOutput, tag) {}.configure(conf)
  end

  def test_configure
    d = create_driver %[
      type kubernetes_tagged_remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
    ]

    d.run do
      d.emit(message: "foo")
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    refute_empty loggers

    logger = loggers.values.first

    assert_equal "example.com", logger.instance_variable_get(:@remote_hostname)
    assert_equal 5566, logger.instance_variable_get(:@remote_port)

    p = logger.instance_variable_get(:@packet)
    assert_equal "foo.com", p.hostname
    assert_equal 1, p.facility
    assert_equal "minitest", p.tag
    assert_equal 7, p.severity
  end

  def test_rewrite_tag
    d = create_driver %[
      type kubernetes_tagged_remote_syslog
      hostname foo.com
      host example.com
      port 5566
      severity debug
      tag rewrited.${tag_parts[1]}
    ]

    d.run do
      d.emit(message: "foo")
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    logger = loggers.values.first

    p = logger.instance_variable_get(:@packet)
    assert_equal "rewrited.kubernetes_tagged_remote_syslog", p.tag
  end
end
