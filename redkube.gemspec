# -*- encoding: utf-8 -*-

GEM_NAME = "redkube"

lib = File.expand_path("../lib", __FILE__)
$: << lib unless $:.include?(lib)

require "redkube/version"

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = RedKube::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hemant Kumar"]
  s.description = %q{For Kubernetes}
  s.email = %q{hemant@codemancers.com}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.homepage = %q{http://redkube.codemancers.com}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.summary = %q{For kube}
  s.add_dependency("thor", "~> 0.20.0")
end
