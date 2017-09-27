module RedKube
  class Pod < Common
    attr_accessor :pvc_name

    def self.from_erb(erb_file, pod_name, pvc_name = nil)
      pod = Pod.new()
      if pvc_name
        pod.pvc_name = pvc_name
      end

      pod.name = pod_name

      pod_erb = ERB.new(erb_file)
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

        if loaded && self.status
          status["phase"] == "Running"
        else
          false
        end
      end
    end

    def delete
      delete_cmd = "#{RedKube.cmd} delete pod #{name}"
      puts "Running #{delete_cmd}"
      `#{delete_cmd}`

      check_status do
        get_command = "#{RedKube.cmd} get pod #{name} -o json"
        output = `#{get_command}`

        if $? != 0
          true
        else
          load_from_json(output)
          false
        end
      end
    end

    def delete_pod_without_wait
      delete_cmd = "#{RedKube.cmd} delete pod #{name}"
      puts "Running #{delete_cmd}"
      `#{delete_cmd}`
    end
  end
end
