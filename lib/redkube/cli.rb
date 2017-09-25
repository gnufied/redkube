require 'thor'

module RedKube
  class CLI < Thor


    desc "pod_mark", "Run pod mark"
    option :sc,
      type: :string,
      banner: "Storageclass to use"
    def pod_mark(run_name)
      RedKube.run_name(run_name)

      sc = "slow"

      if options[:sc] && !options[:sc].empty?
        sc = options[:sc]
      end
      RedKube::PodMark.new().start(sc)
    end
  end
end
