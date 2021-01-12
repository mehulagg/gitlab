# frozen_string_literal: true

module CanHousekeep
  extend ActiveSupport::Concern

  def pushes_since_gc_redis_shared_state_key
    "#{self.class.name.underscore.pluralize}/#{id}/pushes_since_gc"
  end

  def pushes_since_gc
    Gitlab::Redis::SharedState.with { |redis| redis.get(pushes_since_gc_redis_shared_state_key).to_i }
  end

  def increment_pushes_since_gc
    Gitlab::Redis::SharedState.with { |redis| redis.incr(pushes_since_gc_redis_shared_state_key) }
  end

  def reset_pushes_since_gc
    Gitlab::Redis::SharedState.with { |redis| redis.del(pushes_since_gc_redis_shared_state_key) }
  end
end
