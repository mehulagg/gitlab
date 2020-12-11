# frozen_string_literal: true

# Promotes survivors from eden to old gen and runs a compaction.
#
# aka "Nakayoshi GC"
#
# https://github.com/puma/puma/blob/de632261ac45d7dd85230c83f6af6dd720f1cbd9/lib/puma/util.rb#L26-L35
def nakayoshi_gc
  4.times { GC.start(full_mark: false) }
  GC.compact
end

gc_stat_keys = ENV['GC_STAT_KEYS'].to_s.split(',').map(&:to_sym)

module GC::Profiler
  class << self
    attr_accessor :ignored

    %i[enable disable clear].each do |method|
      alias_method "#{method}_orig", "#{method}"

      define_method(method) do
        if ignored
          $stderr.puts "Ignoring #{method} call."
          return
        end

        send("#{method}_orig")
      end
    end
  end
end

GC::Profiler.enable
GC::Profiler.ignored = true

require 'benchmark'

tms = Benchmark.measure do
  require_relative 'config/boot'
  require_relative 'config/environment'
end

GC::Profiler.ignored = false

nakayoshi_gc

gc_stats = GC.stat
gc_total_time = GC::Profiler.total_time
$stderr.puts(gc_stats)

GC::Profiler.report($stderr)
GC::Profiler.disable

values = []
values << ENV['DESC']
values += gc_stat_keys.map { |k| gc_stats[k] }
values << ::Gitlab::Metrics::System.memory_usage_rss
values << gc_total_time
values << tms.utime+tms.cutime
values << tms.stime+tms.cstime
values << tms.real

puts values.join(',')
