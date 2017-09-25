module RedKube
  class Benchmark
    def initialize
      @benchmark_results = Hash.new() { |h, k|  h[k] = [] }
    end

    def benchmark(key)
      10.times do |i|
        t1 = Time.now()
        yield i
        diff = TIme.now() - t1
        @benchmark_results[key][i] << diff
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
