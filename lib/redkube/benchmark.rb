module RedKube
  class Benchmark
    def initialize
      @benchmark_results = {}
    end

    def benchmark(key)
      5.times do |i|
        t1 = Time.now()
        yield i
        diff = Time.now() - t1
        puts "Running #{key} took #{diff} seconds"
        @benchmark_results[key] ||= []
        @benchmark_results[key] << diff
      end
      print_results()
    end

    def print_results
      @benchmark_results.each do |key, value|
        average = value.sum() / value.size()
        Puts "Operation #{key} took on average #{average}"
      end
    end
  end
end
