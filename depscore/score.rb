class Score
  def initialize
    @weights = {
      tot_downloads: 0.5,
      reverse_dep_count: 1,
      latest_vesion_age: -2,
      release_feq_1yer: 1,

    }
    @threshold = {
      tot_downloads: 100000,
      reverse_dep_count: 100,
      latest_vesion_age: 24,
      release_feq_1yer: 12,
    }
  end

  def compute_score(signals)
    inside = 0.0
    outside = 0.0
    score = 0.0

    signals.each do |signal, value|
      # puts "Singal: #{signal} Value: #{value}"
      # add skip if not found
      if @threshold.key?(signal)
        threshold = @threshold[signal]
        # puts threshold
        weight = @weights[signal]
        # puts weight
        inside += (Math.log(1 + value) / Math.log(1 + [value, threshold].max)) * weight
      end
    end

    @weights.each do |weight, value|
      outside += value
    end

    score = (1 / outside) * inside
    final_score = ([[score, 1].min, 0].max).round(1)
    # puts "The score = #{final_score}"
    return final_score
  end
end
