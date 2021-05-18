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
    if shard_name = subject&.database_shard_name
      NamespaceShard.connected_to(role: :writing, shard: shard_name, &block)
    else
      NamespaceShard.connected_to(role: :writing, shard: all_shards.sample.to_sym, &block)
    end
  end

  def self.stick_if_not(subject, &block)
    if NamespaceShard.current_shard == :default
      sticky_shard(subject, &block)
    else
      yield
    end
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

  def self.find_all(&block)
    results = []

    all_shards.each do |shard_name|
      NamespaceShard.connected_to(role: :reading, shard: shard_name.to_sym) do
        results += block.call
      end
    end

    results
  end

  def self.read_for_id(id, &block)
    shard_name = ::Gitlab::Sharding::Current.id_to_shard_name(id)

    NamespaceShard.connected_to(role: :reading, shard: shard_name, &block)
  end

  def self.find(id)
    result = self.find_first { super rescue nil } 
    raise ActiveRecord::RecordNotFound unless result
    result
  end
end
