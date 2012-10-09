$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ASSET_PATH = File.expand_path('../assets', __FILE__)

require 'mochilo'
require 'json'
require 'benchmark'
require 'msgpack'
require 'pp'

def benchmark(filename, repeat = 1000)
  stream = IO.read("#{ASSET_PATH}/#{filename}")
  stream_len = stream.size

  object = JSON.parse(stream)
  bytes = MessagePack.pack(object)

  stream = nil
  GC.start

  def do_bench(label, repeat, &block)
    t = Benchmark::Tms.new

    repeat.times do
      GC.disable
      t = t + Benchmark.measure(nil, &block)
      GC.enable
      GC.start
    end

    puts "-> #{label} x#{repeat}"
    puts " Total:", t
    puts " Avg:", t / repeat
    puts ""
  end

  puts "# #{filename} (#{stream_len / 1024}kb)"
  do_bench('Mochilo (pack)', repeat) { Mochilo.pack(object) }
  do_bench('Msgpack (pack)', repeat) { MessagePack.pack(object) }

  do_bench('Mochilo (unpack)', repeat) { Mochilo.unpack(bytes) }
  do_bench('Msgpack (unpack)', repeat) { MessagePack.unpack(bytes) }
end

benchmark('pulls.json')
