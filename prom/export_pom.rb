#!/usr/bin/env ruby

require 'signalfx'
require 'yaml'


class Metric
  attr_accessor :name, :value, :dims, :mtype
  def initialize(name, value)
    @name = name
    @value = value.to_f
    if name =~ /_(count|sum)$/
      @mtype = "cumulative"
    else
      @mtype = "gauge"
    end
    @dims = {}
  end

  def set_dims(dim_string)
    return if !dim_string
    dim_string.strip!
    return if dim_string.empty?

    dim_array = dim_string.split(",")
    dim_array.each do |dim|
      k, v = dim.split("=")
      k.strip!
      v.strip!
      @dims[k] = v
    end
  end

  def add_dims(k, v)
    @dimes[k] = v
  end
end

class MetricCollection
  attr_accessor :metrics, :raw_data
  def initialize(data, ip, role)
    @raw_data = data
    @metrics = []
    @ip = ip
    @role = role
  end

  def parse_metric
    return if !raw_data
    raw_data.strip!
    return if raw_data.empty?

    raw_data.split("\n").each do |metric_line|
      next if metric_line =~ /^#/
      name, rest = metric_line.split("{", 2)
      dim_string, value = rest.split("}", 2)

      metric = Metric.new(name, value)

      metric.set_dims(dim_string)
      metric.add_dims("ip", @ip)
      metric.add_dims("role", @role)
      @metrics << metric
    end
  end

  def signalfx_metric
    signalfx_data = {cumulative_counters: [], gauges: [], counters: {}}
    metrics.each do |metric|
      case metric.mtype
      when "cumulative"
        signalfx_data[:cumulative_counters] << {
          :metric => metric.name,
          :value => metric.value,
          :timestamp => get_time_msec,
          :dimensions => [metric.dims]
        }
      else
        signalfx_data[:gauges] << {
          :metric => metric.name,
          :value => metric.value,
          :timestamp => get_time_msec,
          :dimensions => [metric.dims]
        }
      end
    end
    signalfx_data
  end

  def get_time_msec
    ftime = Time.now.to_f
    (ftime*1000).to_i
  end

  def blank?
    metrics.empty?
  end

  def size
    metrics.size
  end
end

class ExportPrometheus
  attr_accessor :config
  def initialize(config_file)
    @config = YAML.load(File.read(config_file))
  end

  def start_emitting
    pids = []
    config.each do |host_config|
      child_pid = fork { collect_metric_from_host(host_config) }
      pids << child_pid
    end
    puts "Waiting for Metric emission to finish"
    Process.waitall
  end

  def collect_metric_from_host(host_config)
    client = SignalFx.new(ENV['SFX_TOKEN'])

    loop do
      cmd_string = "curl --insecure --cert /etc/origin/master/#{host_config['crt']} --key /etc/origin/master/#{host_config['key']} #{host_config['url']}"
      puts "Command to run is #{cmd_string}"
      data = `#{cmd_string}`
      metric_collection = MetricCollection.new(data, host_config['ip'], host_config['role'])
      metric_collection.parse_metric
      if !metric_collection.blank?
        puts "********** Sending total of #{metric_collection.size} metrics"
        client.send(metric_collection.signalfx_metric)
      end

      sleep(60)
    end
  end
end

filename = ARGV[0]
puts filename
t = ExportPrometheus.new(filename)
t.start_emitting
