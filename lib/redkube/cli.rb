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
    def pod_mark(run_name)
      sc = "slow"

      if options[:sc] && !options[:sc].empty?
        sc = options[:sc]
      end

      if options[:cmd] && !options[:cmd].empty?
        RedKube.cmd(options[:cmd])
      end

      RedKube.run_name(run_name)
      RedKube::PodMark.new().start(sc)
    end
  end
end
