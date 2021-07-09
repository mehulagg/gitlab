class LibData
  @@array = Array.new
  attr_accessor :signals, :name

  Signals = Struct.new(:tot_downloads,
  :reverse_dep_count,
  :latest_vesion_age,
  :version,
  :lang,
  :latest_release_on,
  :rel_freq_last_4quater,
  :file,
  :score
  )


  def self.all_instances
    @@array
  end

  def initialize (name, opts)
    @@array << self
    @name = name
    @signals = Signals.new(opts[:tot_downloads],opts[:reverse_dep_count],opts[:latest_vesion_age],opts[:version],opts[:lang],opts[:latest_release_on],opts[:rel_freq_last_4quater],opts[:file],opts[:score])
  end
end
