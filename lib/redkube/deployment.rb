module RedKube
  class Deployment < Common
    attr_accessor :pvc_names
    def self.from_erb(erb_file, dc_name, *pvc_names)
      deployment = Deployment.new()

      if !pvc_names.empty?
        deployment.pvc_names = pvc_names
      end
      deployment.name = dc_name
      deployment_yaml = write_yaml_file(erb_file, deployment)
      deployment.create_resource(deployment_yaml)
      deployment
    end

    def check_if_up
      check_status do
        t = `#{RedKube.cmd} get deployments #{dc_name} -o json`
        load_from_json(t)

        if loaded && self.status
          status["availableReplicas"] == 1
        else
          false
        end
      end
    end

    def check_if_down
      check_status do
        t = `#{RedKube.cmd} get deployments #{dc_name} -o json`
        load_from_json(t)

        if loaded && self.status
          status["availableReplicas"] == 0
        else
          false
        end
      end
    end
  end
end
