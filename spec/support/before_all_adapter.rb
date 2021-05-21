# frozen_string_literal: true

# Rewritten based on: https://github.com/test-prof/test-prof/blob/master/lib/test_prof/before_all/adapters/active_record.rb
class BeforeAllAdapter
  MODELS = [::ApplicationRecord, ::Ci::ApplicationRecord]

  def self.models
    MODELS
  end

  def self.all_connection_pools
    #::ActiveRecord::Base.connection_handler.all_connection_pools
    MODELS.map(&:connection_pool)
  end

  def self.begin_transaction
    debug_puts "BeforeAllAdapter.begin_transaction: #{::ActiveRecord::Base.connection_handler.connection_pool_names}"

    # iterate all registered connection handlers (aka different connection databases)
    self.all_connection_pools.each do |connection_pool|
      connection_pool.connection.begin_transaction(joinable: false)
      debug_puts "BeforeAllAdapter.begin_transaction: #{connection_pool.db_config.name} / #{connection_pool.object_id} / #{connection_pool.connection.object_id} / #{connection_pool.connection.open_transactions}"
    end
  end

  def self.rollback_transaction
    debug_puts "BeforeAllAdapter.rollback_transaction"

    # iterate all registered connection handlers (aka different connection databases)
    self.all_connection_pools.each do |connection_pool|
      debug_puts "BeforeAllAdapter.rollback_transaction: #{connection_pool.db_config.name} / #{connection_pool.object_id} / #{connection_pool.connection.object_id} / #{connection_pool.connection.open_transactions}"
      if connection_pool.connection.open_transactions.zero?
        warn "!!! before_all transaction has been already rollbacked and " \
              "could work incorrectly"
        next
      end

      connection_pool.connection.rollback_transaction
    end
  end

  def self.debug_puts(*params)
    return unless ENV['DB_DEBUG']

    puts(*params)
  end

  def self.setup_fixtures(test_object)
    test_object.instance_eval do
      @@already_loaded_fixtures ||= {}
      @fixture_cache ||= {}
      config = self.class.superclass

      if @@already_loaded_fixtures[self.class]
        @loaded_fixtures = @@already_loaded_fixtures[self.class]
      else
        @loaded_fixtures = load_fixtures(config)
        @@already_loaded_fixtures[self.class] = @loaded_fixtures
      end
    end
  end
end

BeforeAllAdapter.prepend_mod_with('BeforeAllAdapter')
