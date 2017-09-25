$: << File.dirname(__FILE__) unless $:.include?(File.expand_path(File.dirname(__FILE__)))


require 'erb'
require 'json'


require "redkube/common"
require "redkube/benchmark"

require "redkube/version"
require "redkube/pod"
require "redkube/pvc"
require "redkube/pod_mark"
require "redkube/cli"

require 'fileutils'

module RedKube
  CONFIG_DIR = File.expand_path(File.join(File.expand_path(File.dirname(__FILE__)), "../config"))
  @run_name = "default"
  def self.run_name(default_run_name = "default")
    if default_run_name
      @run_name = default_run_name
    end
    @run_name
  end

  def self.tmp_path
    fl_path = File.join("/tmp/#{run_name}")
    if !File.exist?(fl_path)
      FileUtils.mkdir(fl_path)
    end
    fl_path
  end

  def self.cmd
    "kubectl"
  end
end
