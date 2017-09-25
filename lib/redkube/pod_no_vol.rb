require 'erb'

module RedKube
  class PodNoVol < Benchmark
    def start(sc_name)
      pod_yaml = File.read("#{RedKube::CONFIG_DIR}/pod_no_vol.yaml")


      benchmark("pod_creation", 1) do |index|
        pod_name = "novol-pod-#{index}"
        puts "Creating pod #{pod_name}"

        pod = Pod.from_erb(pod_yaml, pod_name, nil)
        pod.check_for_pod
      end

      benchmark("create_delete_loop", 5) do |i|
        benchmark("pod_delete_recreate", 1) do |index|
          pod_name = "novol-pod-#{index}"

          puts "Recreating pod #{pod_name}"
          pod = Pod.new()
          pod.name = pod_name

          pod.delete

          pod = Pod.from_erb(pod_yaml, pod_name, nil)
          pod.check_for_pod
        end
      end
    end
  end
end
