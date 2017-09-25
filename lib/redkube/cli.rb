require 'thor'

module RedKube
  class CLI < Thor


    desc "pod_mark", "Run pod mark"
    option :sc,
      type: :string,
      banner: "Storageclass to use"
    option :cmd,
      type: :string,
      banner: "binary name to use"
    option :run,
      type: :string,
      banner: "Which benchmark to run"
    def pod_mark(run_name)
      sc = "slow"

      if options[:sc] && !options[:sc].empty?
        sc = options[:sc]
      end

      if options[:cmd] && !options[:cmd].empty?
        RedKube.cmd(options[:cmd])
      end

      RedKube.run_name(run_name)
      klass_to_run = "PodMark"

      if options[:run] && !options[:run].empty?
        klass_to_run = options[:run]
      end
      klass = RedKube.const_get(klass_to_run.to_sym)
      klass.new().start(sc)
    end
  end
end
