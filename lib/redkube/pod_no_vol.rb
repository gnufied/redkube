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

      benchmark("create_delete_loop", 500) do |i|
        benchmark("pod_delete_recreate", 1) do |index|
          t1 = Time.now
          pod_name = "novol-pod-#{index}"

          puts "Recreating pod #{pod_name}"
          pod = Pod.new()
          pod.name = pod_name

          pod.delete
          puts "Time taken to delete pod #{Time.now() - t1}"

          t2 = Time.now()
          pod = Pod.from_erb(pod_yaml, pod_name, nil)
          pod.check_for_pod
          puts "Time taken to create pod #{Time.now() - t2}"
        end
      end
    end
  end
end
