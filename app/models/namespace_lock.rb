# frozen_string_literal: true

class NamespaceLock < ApplicationRecord
  def self.shared(id, &block)
    with_lock(id, 'FOR SHARE', &block)
  end

  def self.exclusive(id, &block)
    with_lock(id, 'FOR UPDATE', &block)
  end

  def self.with_lock(id, kind)
    transaction do
      # We do not retry any locking failures. If an actor holds on to the
      # exclusive lock long enough (e.g. when moving data between shards is
      # taking longer than expected), any actors trying to obtain a shared lock
      # would retry this operation. This could result in lots of waiting
      # requests, blocking other more useful work in the process.
      if where(namespace_id: id).lock(kind).limit(1).take.nil?
        raise ArgumentError, "No group exists for ID #{id}"
      end

      yield
    end
  end
end
