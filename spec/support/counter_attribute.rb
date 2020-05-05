# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all, :counter_attribute) do
    connection = ActiveRecord::Base.connection
    connection.create_table :test_counter_attributes, if_not_exists: true do |t|
      t.integer :project_id
      t.integer :counter_a, null: false, default: 0
      t.integer :counter_b, null: false, default: 0
    end

    connection.create_table :test_counter_attribute_events, if_not_exists: true do |t|
      t.integer :test_counter_attribute_id
      t.integer :counter_a, null: false, default: 0
      t.integer :counter_b, null: false, default: 0
    end
  end

  config.after(:all, :counter_attribute) do
    connection = ActiveRecord::Base.connection
    connection.drop_table :test_counter_attributes
    connection.drop_table :test_counter_attribute_events
  end

  config.before(:each, :counter_attribute) do
    stub_const('TestCounterAttribute', Class.new(ApplicationRecord))
    stub_const('TestCounterAttributeEvent', Class.new(ApplicationRecord))

    TestCounterAttribute.class_eval do
      belongs_to :project

      include CounterAttribute

      counter_attribute :counter_a
      counter_attribute :counter_b
    end

    TestCounterAttributeEvent.class_eval do
      belongs_to :test_counter_attribute
    end
  end
end
