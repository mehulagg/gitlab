# frozen_string_literal: true

class NamespaceShard < ApplicationRecord
  self.abstract_class = true

  configured_database_names = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).map(&:name)
  default_shard = { default: { writing: :primary, reading: :primary } }

  if configured_database_names.size > 1
    # TODO check that a database named 'primary' exists
    # TODO use `.default_shard`, `.writing_role`, `.reading_role`, rather then fixed symbols
    sharded_database_names = configured_database_names - ['primary']
    connects_to_shards = sharded_database_names.each_with_object({}) { |name, hash| hash[name.to_sym] = { writing: name.to_sym, reading: name.to_sym } }

    connects_to shards: default_shard.merge(connects_to_shards)
  else
    connects_to shards: default_shard
  end

  def database_shard_id
    self.class.id_to_shard(id) if id
  end

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
    Rails.logger.info "SHARD - #{shard}"

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
      :shard_1
    else
      :default
    end
  end

  def self.id_to_shard(id)
    (id >> 10) & (1<<13 - 1)
  end

  # The intention is to eventually lookup from a DB
  def self.find_shard_from_namespace_id(namespace_id)
    shard_id = id_to_shard(namespace_id.to_i)
    if shard_id > 0
      :"shard_#{shard_id}"
    else
      :primary
    end
  end
end
