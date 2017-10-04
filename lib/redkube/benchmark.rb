module RedKube
  class Benchmark

    def benchmark(key, count)
      benchmark_results = {}
      count.times do |i|
        t1 = Time.now()
        yield i
        diff = Time.now() - t1
        benchmark_results[key] ||= []
        benchmark_results[key] << diff
      end
      print_results(benchmark_results)
    end

    def print_results(benchmark_results)
      benchmark_results.each do |key, value|
        sum = value.inject(0) { |mem, obj| mem + obj }
        average = sum / value.size()
        puts "Operation #{key} took on average #{average}"
      end
    end

    def get_hostname
      hostname = `hostname`
      hostname.strip
    end
  end
end
