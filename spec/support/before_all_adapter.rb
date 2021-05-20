# frozen_string_literal: true

# Rewritten based on: https://github.com/test-prof/test-prof/blob/master/lib/test_prof/before_all/adapters/active_record.rb
class BeforeAllAdapter
  def self.begin_transaction
    # iterate all registered connection handlers (aka different connection databases)
    ::ActiveRecord::Base.connection_handler.all_connection_pools.each do |connection_pool|
      connection_pool.connection.begin_transaction(joinable: false)
    end
  end

  def self.rollback_transaction
    # iterate all registered connection handlers (aka different connection databases)
    ::ActiveRecord::Base.connection_handler.all_connection_pools.each do |connection_pool|
      if connection_pool.connection.open_transactions.zero?
        warn "!!! before_all transaction has been already rollbacked and " \
              "could work incorrectly"
        next
      end

      connection_pool.connection.rollback_transaction
    end
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
