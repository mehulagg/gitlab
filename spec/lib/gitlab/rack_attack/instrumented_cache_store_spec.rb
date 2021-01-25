# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RackAttack::InstrumentedCacheStore do
  using RSpec::Parameterized::TableSyntax

  let(:store) { ::ActiveSupport::Cache::NullStore.new }

  subject { described_class.new(upstream_store: store)}

  where(:operation, :params) do
    :fetch | [:key]
    :fetch | [:key]
    :read | [:key]
    :read | [:key]
    :read_multi | [:key_1, :key_2, :key_3]
    :write_multi | [{ key_1: 1, key_2: 2, key_3: 3 }]
    :fetch_multi | [:key_1, :key_2, :key_3]
    :write | [:key, :value, { option_1: 1 }]
    :delete | [:key]
    :exist? | [:key, { option_1: 1 }]
    :delete_matched | [/^key$/, { option_1: 1 }]
    :increment | [:key, 1]
    :decrement | [:key, 1]
    :cleanup | []
    :clear | []
  end

  with_them do
    it 'publishes a notification' do
      published = false

      begin
        subscriber = ActiveSupport::Notifications.subscribe("rack_attack.redis") do |*args|
          published = true
          event = ActiveSupport::Notifications::Event.new(*args)
          expect(event.name).to eq("rack_attack.redis")
          expect(event.duration).to be_a(Float).and(be > 0.0)
          expect(event.payload[:operation]).to eql(operation)
        end

        subject.send(operation, *params) {}
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
      end

      expect(published).to be(true)
    end

    it 'publishes a notification even if the cache store returns an error' do
      allow(store).to receive(operation).and_raise("Some thing went wrong")
      published = false
      exception = false

      begin
        subscriber = ActiveSupport::Notifications.subscribe("rack_attack.redis") do |*args|
          published = true
          event = ActiveSupport::Notifications::Event.new(*args)
          expect(event.name).to eq("rack_attack.redis")
          expect(event.duration).to be_a(Float).and(be > 0.0)
          expect(event.payload[:operation]).to eql(operation)
        end

        begin
          subject.send(operation, *params) {}
        rescue
          # Ignore the error
          exception = true
        end
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
      end

      expect(published).to be(true)
      expect(exception).to be(true)
    end

    it 'delegates to the upstream store' do
      if params.empty?
        expect(store).to receive(operation).with(no_args)
      else
        expect(store).to receive(operation).with(*params)
      end

      subject.send(operation, *params)
    end
  end
end
