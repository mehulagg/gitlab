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

outfile = ENV['OUTFILE']
gc_stat_keys = ENV['GC_STAT_KEYS'].split(',').map(&:to_sym)

nakayoshi_gc

gc_stats = GC.stat
p gc_stats

File.open(outfile, 'a') do |f|
  values = gc_stat_keys.map { |k| gc_stats[k] }
  rss = `ps -p #{$$} -o rss=`.strip
  line = "#{values.join(',')},#{rss}"
  puts line + "\n"
  f << line
end
