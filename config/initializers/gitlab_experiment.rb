# frozen_string_literal: true

Gitlab::Experiment.configure do |config|
  config.base_class = 'ApplicationExperiment'
  config.mount_at = Feature.enabled?(:gitlab_experiment_middleware) ? '/-/experiment/' : nil
  config.cache = Gitlab::Experiment::Cache::RedisHashStore.new(
    pool: ->(&block) { Gitlab::Redis::SharedState.with { |redis| block.call(redis) } }
  )

  # TODO: This will be deprecated as of v0.6.0, but needs to stay intact for
  #  actively running experiments until a versioning concept is put in place to
  #  enable migrating into the new SHA2 strategy.
  config.context_hash_strategy = lambda do |source, seed|
    source = source.keys + source.values if source.is_a?(Hash)
    Digest::MD5.hexdigest(Array(source).map { |v| identify(v) }.unshift(seed).join('|'))
  end
end
