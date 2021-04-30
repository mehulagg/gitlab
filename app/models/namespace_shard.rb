# frozen_string_lteral: true

class NamespaceShard < ApplicationRecord
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :shard_one, reading: :shard_one }
  }

  def self.sharded_read_from_namespace_id(namespace_id, &block)
    raise "No block given" unless block_given?

    shard = find_shard_from_namespace_id(namespace_id)

    NamespaceShard.connected_to(role: :reading, shard: shard, &block)
  end

  def self.sharded_read_from_full_path(full_path, &block)
    raise "No block given" unless block_given?

    shard = find_shard_from_full_path(full_path)

    NamespaceShard.connected_to(role: :reading, shard: shard, &block)
  end

  def self.sharded_read(namespace: nil, shard: nil, &block)
    raise "No block given" unless block_given?
    raise "Namespace or shard must be provided" if namespace.nil? && shard.nil?

    shard ||= find_shard_from_namespace(namespace)

    NamespaceShard.connected_to(role: :reading, shard: shard, &block)
  end

  def self.sharded_write(namespace: nil, shard: nil, &block)
    raise "No block given" unless block_given?
    raise "Namespace or shard must be provided" if namespace.nil? && shard.nil?

    shard ||= find_shard_from_namespace(namespace)
    Rails.logger.info "SHARD - #{shard}"

    NamespaceShard.connected_to(role: :writing, shard: shard, &block)
  end

  # The intention is to eventually lookup from a DB
  def self.find_shard_from_namespace(namespace)
    # Assumes that the Route was preloaded from the same shard as namespace
    find_shard_from_full_path(namespace.full_path)
  end

  # The intention is to eventually lookup from a DB
  def self.find_shard_from_full_path(full_path)
    if full_path == 'lost-and-found' || full_path.start_with?('lost-and-found/')
      :shard_one
    else
      :default
    end
  end

  # The intention is to eventually lookup from a DB
  def self.find_shard_from_namespace_id(namespace_id)
    if namespace_id.to_i == 2
      :shard_one
    else
      :default
    end
  end
end
