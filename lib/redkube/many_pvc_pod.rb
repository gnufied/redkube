module RedKube
  class ManyPVCPod < Pod
    attr_accessor :pvc_names
    def self.from_erb(erb_file, pod_name, *pvc_names)
      pod = ManyPVCPod.new()

      if !pvc_names.empty?
        pod.pvc_names = pvc_names
      end

      pod.name = pod_name

      pod_erb = ERB.new(erb_file)
      yaml_result = pod_erb.result(pod.get_binding)
      pod_path = "#{RedKube.tmp_path}/#{pod_name}.yaml"

      File.open(pod_path, "w") do |fl|
        fl.write(yaml_result)
      end
      pod.create_pod_from_yaml(pod_path)
      pod
    end
  end
end
