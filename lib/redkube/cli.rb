require 'thor'

module RedKube
  class CLI < Thor


    desc "pod_mark", "Run pod mark"
    def pod_mark
      RedKube::PodMark.start()
    end
  end
end
