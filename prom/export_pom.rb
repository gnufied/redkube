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
    return if !dim_string || dim_string.empty?

    dim_array = dim_string.split(",")
    dim_array.each do |dim|
      k, v = dim.split("=")
      k = k.strip
      v = v.strip
      k = unquote(k)
      v = unquote(v)
      @dims[k] = v
    end
  end

  def unquote(incoming)
    s = incoming.dup

    case incoming[0,1]
    when "'", '"', '`'
      s[0] = ''
    end

    case incoming[-1,1]
    when "'", '"', '`'
      s[-1] = ''
    end

    return s
  end

  def add_dims(k, v)
    @dims[k] = v
  end

  def get_sfx_dims
    sfx_dims = []
    @dims.each do |key,value|
      sfx_dims << {:key => key, :value => value}
    end
    sfx_dims
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

    if raw_data && !raw_data.empty?

      raw_data.split("\n").each do |metric_line|
        next if metric_line =~ /^#/
        name, rest = metric_line.split("{", 2)
        if rest
          dim_string, value = rest.split("}", 2)

          metric = Metric.new(name, value)

          metric.set_dims(dim_string)
          metric.add_dims("ip", @ip)
          metric.add_dims("role", @role)
          @metrics << metric
        else
          name, value = metric_line.split(" ")
          metric = Metric.new(name, value)
          metric.add_dims("ip", @ip)
          metric.add_dims("role", @role)
          @metrics << metric
        end
      end
    end

  end

  def signalfx_metric
    signalfx_data = {cumulative_counters: [], gauges: [], counters: {}}
    metrics.each do |metric|
      if metric.name == "storage_operation_duration_seconds_sum"
        puts "Sending metrics with dimensions #{metric.dims} and value #{metric.value} and time #{get_time_msec()}"
      end

      case metric.mtype
      when "cumulative"
        signalfx_data[:cumulative_counters] << {
          :metric => metric.name,
          :value => metric.value,
          :timestamp => get_time_msec(),
          :dimensions => metric.get_sfx_dims()
        }
      else
        signalfx_data[:gauges] << {
          :metric => metric.name,
          :value => metric.value,
          :timestamp => get_time_msec(),
          :dimensions => metric.get_sfx_dims()
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
      ip = host_config['ip']
      metric_collection = MetricCollection.new(data, ip, host_config['role'])
      metric_collection.parse_metric
      if !metric_collection.blank?
        sfx_metrics = metric_collection.signalfx_metric
        puts "********** Sending total of cm_ct: #{sfx_metrics[:cumulative_counters].size} metrics for #{ip} #{Time.now}"
        puts "********** Sending total of gauge: #{sfx_metrics[:gauges].size} metrics for #{ip} #{Time.now}"
        puts "********** Sending total of counters: #{sfx_metrics[:counters].size} metrics for #{ip} #{Time.now}"
        client.send_async(sfx_metrics)
      end

      sleep(30)
    end
  end
end

filename = ARGV[0]
puts filename
t = ExportPrometheus.new(filename)
t.start_emitting
