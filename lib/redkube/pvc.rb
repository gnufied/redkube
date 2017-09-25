module RedKube
  class PVC < Common
    attr_accessor :sc_name

    def self.from_erb(erb_file, pvc_name, sc_name)
      pvc = PVC.new()
      pvc.name = pvc_name
      pvc.sc_name = sc_name

      pvc_erb = ERB.new(erb_file)
      yaml_result = pvc_erb.result(pvc.get_binding)
      pvc_path = "#{RedKube.tmp_path}/#{pvc_name}.yaml"
      puts pvc_path
      File.open(pvc_path, "w") do |fl|
        fl.write(yaml_result)
      end
      system("#{RedKube.cmd} create -f #{pvc_path}")
      pvc
    end

    def check_for_pvc
      check_status() do
        t = `#{RedKube.cmd} get pvc #{name} -o json`
        load_from_json(t)

        if loaded && self.status
          status["phase"] == "Bound"
        else
          false
        end
      end
    end
  end
end
