require 'json'

module RedKube
  class Common
    attr_accessor :name, :namespace, :uid, :loaded, :metadata, :status, :spec

    def initialize
      self.loaded = false
    end

    def load_from_json(json_data)
      if json_data
        json_data = json_data.strip!
        if json_data && !json_data.empty?
          json_object = JSON.load(json_data)
          load_metadata(json_object['metadata'])
          load_status(json_object['status'])
          load_spec(json_object['spec'])
          self.loaded = true
        end
      end
    end

    def get_binding
      binding()
    end

    def check_status()
      loop do
        begin
          t = yield
          break if t
        rescue; end
        sleep(2)
      end
    end

    def load_metadata(meta_data)
      self.metadata = meta_data
      self.name = meta_data['name']
      self.namespace = meta_data['namespace']
      self.uid = meta_data['uid']
    end

    def load_status(status_data)
      self.status = status_data
    end

    def load_spec(spec_data)
      self.spec = spec_data
    end
  end
end
