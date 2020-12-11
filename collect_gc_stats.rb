#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'

SETTINGS = {
  'DEFAULTS' => [''],
  # Default: 10_000
  'RUBY_GC_HEAP_INIT_SLOTS' => %w[100000 1000000 5000000],
  # Default: 1.8
  'RUBY_GC_HEAP_GROWTH_FACTOR' => %w[1.2 1 0.8],
  # Default: 0 (disabled)
  'RUBY_GC_HEAP_GROWTH_MAX_SLOTS' => %w[10000 100000 1000000],
  # Default: 2.0
  'RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR' => %w[2.5 1.5 1],
  # Default: 4096 (= 2^12)
  'RUBY_GC_HEAP_FREE_SLOTS' => %w[16384 2048 0],
  # Default: 0.20 (20%)
  'RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO' => %w[0.1 0.01 0.001],
  # Default: 0.40 (40%)
  'RUBY_GC_HEAP_FREE_SLOTS_GOAL_RATIO' => %w[0.2 0.01 0.001],
  # Default: 0.65 (65%)
  'RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO' => %w[0.2 0.02 0.002],
  # Default: 16MB
  'RUBY_GC_MALLOC_LIMIT' => %w[8388608 4194304 1048576],
  # Default: 32MB
  'RUBY_GC_MALLOC_LIMIT_MAX' => %w[16777216 8388608 1048576],
  # Default: 1.4
  'RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR' => %w[1.6 1 0.8],
  # Default: 16MB
  'RUBY_GC_OLDMALLOC_LIMIT' => %w[8388608 4194304 1048576],
  # Default: 128MB
  'RUBY_GC_OLDMALLOC_LIMIT_MAX' => %w[33554432 16777216 1048576],
  # Default: 1.2
  'RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR' => %w[1.4 1 0.8]
}.freeze

ALL_GCSTAT_KEYS = [
  :heap_allocated_pages,
  :heap_sorted_length,
  :heap_allocatable_pages,
  :heap_available_slots,
  :heap_live_slots,
  :heap_free_slots,
  :heap_final_slots,
  :heap_marked_slots,
  :heap_eden_pages,
  :heap_tomb_pages,
  :total_allocated_pages,
  :total_freed_pages,
  :total_allocated_objects,
  :total_freed_objects,
  :malloc_increase_bytes,
  :malloc_increase_bytes_limit,
  :minor_gc_count,
  :major_gc_count,
  :compact_count,
  :remembered_wb_unprotected_objects,
  :remembered_wb_unprotected_objects_limit,
  :old_objects,
  :old_objects_limit,
  :oldmalloc_increase_bytes,
  :oldmalloc_increase_bytes_limit
].freeze

USED_GCSTAT_KEYS = [
  :minor_gc_count,
  :major_gc_count,
  :heap_live_slots,
  :heap_free_slots,
  :total_allocated_pages,
  :total_freed_pages,
  :malloc_increase_bytes,
  :malloc_increase_bytes_limit,
  :oldmalloc_increase_bytes,
  :oldmalloc_increase_bytes_limit
].freeze

CSV_USED_GCSTAT_KEYS = USED_GCSTAT_KEYS.join(',')
CSV_HEADER = "setting,value,#{CSV_USED_GCSTAT_KEYS},RSS,gc_time_s,user_cpu_time_s,system_cpu_time_s,real_time_s\n"

def collect_stats(setting, value)
  $stderr.puts "#{setting}=#{value}..."
  env = {
    setting => value,
    'DESC' => "#{setting},#{value}",
    'GC_STAT_KEYS' => CSV_USED_GCSTAT_KEYS
  }
  system(env, 'ruby', './print_gc_stats.rb')
end

par = ENV['PAR']&.to_i || 2
batch_size = (SETTINGS.size.to_f / par).ceil
batches = SETTINGS.each_slice(batch_size)

$stderr.puts "Requested parallelism: #{par} (batches: #{batches.size}, batch size: #{batch_size})"

puts CSV_HEADER

elapsed = Benchmark.realtime do
  threads = batches.each_with_index.map do |settings_batch, n|
    Thread.new do
      settings_batch.each do |setting, values|
        values.each do |v|
          collect_stats(setting, v)
        end
      end
    end
  end

  threads.each(&:join)
end

$stderr.puts "All done in #{elapsed} sec"
