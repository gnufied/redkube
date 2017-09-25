$: << File.dirname(__FILE__) unless $:.include?(File.expand_path(File.dirname(__FILE__)))

require "redkube/version"
require "redkube/pod"
require "redkube/pvc"
require "redkube/pod_mark"
require "redkube/cli"

module RedKube
end
