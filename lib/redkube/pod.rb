module RedKube
  class Pod < Common
    attr_accessor :pvc_name

    def self.from_erb(erb_file, pod_name, pvc_name)
      pod = Pod.new()
      pod.pvc_name = pvc_name
      pod.name = pod_name

      pod_erb = EBR.new(erb_file)
      yaml_result = pod_erb.result(pod.get_binding)
      pod_path = "#{RedKube.tmp_path}/#{pod_name}.yaml"

      File.open(pod_path, "w") do |fl|
        fl.write(yaml_result)
      end
      system("#{RedKube.cmd} create -f #{pod_path}")
      pod
    end

    def check_for_pod
      check_status do
        t = `#{RedKube.cmd} get pod #{name} -o json`
        load_from_json(t)

        if loaded
          return status["phase"] == "Running"
        end
        false
      end
    end

    def delete
      `#{RedKube.cm} delete pod #{name}`

      check_status do
        `#{RedKube.cmd} get pod #{name} - o json`

        if $? != 0
          true
        else
          false
        end
      end
    end
  end
end
