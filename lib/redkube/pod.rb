module RedKube
  class Pod < Common
    attr_accessor :pod_name, :pvc_name
    def get_binding
      binding()
    end
  end
end
