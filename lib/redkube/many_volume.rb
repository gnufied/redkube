require 'erb'


module RedKube
  class ManyVolume < Benchmark
    def start(sc_name)
      pvc_yaml = File.read("#{RedKube::CONFIG_DIR}/dyn-pvc.yaml")
      pod_yaml = File.read("#{RedKube::CONFIG_DIR}/many_vol_pod.yaml")

      benchmark("pod_creation", 27) do |index|
        pvc_name1 = "dyn-pvc-#{index}-1"
        pvc_name2 = "dyn-pvc-#{index}-2"
        pvc_name3 = "dyn-pvc-#{index}-3"

        pvc1 = PVC.from_erb(pvc_yaml, pvc_name1, sc_name)
        pvc1.check_for_pvc

        pvc2 = PVC.from_erb(pvc_yaml, pvc_name2, sc_name)
        pvc2.check_for_pvc

        pvc3 = PVC.from_erb(pvc_yaml, pvc_name3, sc_name)
        pvc3.check_for_pvc

        t1 = Time.now
        pod_name = "dyn-pod-#{index}"
        pod = ManyPVCPod.from_erb(pod_yaml, pod_name, pvc_name1, pvc_name2, pvc_name3)
        pod.check_for_pod
        puts "Time taken to create pod #{Time.now() - t1}"
      end
    end
  end
end
