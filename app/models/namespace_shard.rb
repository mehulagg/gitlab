# frozen_string_literal: true

class NamespaceShard < ApplicationRecord
  self.abstract_class = true

  configured_database_names = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).map(&:name) - ['primary']
  default_shard = { default: { writing: :primary, reading: :primary } }

  if configured_database_names.size > 1
    # TODO check that a database named 'primary' exists
    # TODO use `.default_shard`, `.writing_role`, `.reading_role`, rather then fixed symbols
    sharded_database_names = configured_database_names
    connects_to_shards = sharded_database_names.each_with_object({}) { |name, hash| hash[name.to_sym] = { writing: name.to_sym, reading: name.to_sym } }

    connects_to shards: connects_to_shards
  else
    connects_to shards: default_shard
  end

  def with_shard(&block)
    NamespaceShard.connected_to(role: :writing, shard: database_shard_name, &block)
  end

  def database_shard_id
    ::Gitlab::Sharding::Current.id_to_shard(id) if id
  end

  def database_shard_name
    ::Gitlab::Sharding::Current.id_to_shard_name(id) if id
  end

  def self.all_shards
    all_shards ||= ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).map(&:name) - ['primary']
  end

  def self.sticky_shard(subject, &block)
    shard_name = subject&.current_shard || all_shards.sample.to_sym

    NamespaceShard.connected_to(role: :writing, shard: shard_name, &block)
  end

  def self.random_shard(&block)
    random_shard_name = all_shards.sample.to_sym

    NamespaceShard.connected_to(role: :writing, shard: random_shard_name, &block)
  end

  def self.use_first_shard(&block)
    NamespaceShard.connected_to(role: :writing, shard: all_shards.first.to_sym, &block)
  end

  def self.find_first(&block)
    all_shards.each do |shard_name|
      NamespaceShard.connected_to(role: :reading, shard: shard_name.to_sym) do
        result = block.call
        return result if result
      end
    end

    nil
  end

  def self.read_for_id(id, &block)
    shard_name = ::Gitlab::Sharding::Current.id_to_shard_name(id)

    NamespaceShard.connected_to(role: :reading, shard: shard_name, &block)
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

  # The intention is to eventually lookup from a DB
  def self.find_shard_from_namespace_id(namespace_id)
    ::Gitlab::Sharding::Current.id_to_shard_name(namespace_id.to_i)
  end

  def self.find(id)
    self.find_first { super rescue nil }

    #raise ActiveRecord::RecordNotFound
  end
end
