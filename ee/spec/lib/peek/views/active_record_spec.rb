# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peek::Views::ActiveRecord, :request_store do
  subject { Peek.views.find { |v| v.class.name == Peek::Views::ActiveRecord.name } }

  let(:connection_replica) { double(:connection_replica) }
  let(:connection_primary) { double(:connection_primary) }

  let(:event_1) do
    {
      name: 'SQL',
      sql: 'SELECT * FROM users WHERE id = 10',
      cached: false,
      connection: connection_primary
    }
  end

  let(:event_2) do
    {
      name: 'SQL',
      sql: 'SELECT * FROM users WHERE id = 10',
      cached: true,
      connection: connection_replica
    }
  end

  let(:event_3) do
    {
      name: 'SQL',
      sql: 'UPDATE users SET admin = true WHERE id = 10',
      cached: false,
      connection: connection_primary
    }
  end

  before do
    allow(Gitlab::PerformanceBar).to receive(:enabled_for_request?).and_return(true)
  end

  context 'when database load balancing is not enabled' do
    it 'subscribes and store data into peek views' do
      Timecop.freeze(2021, 2, 23, 10, 0) do
        ActiveSupport::Notifications.publish('sql.active_record', Time.current, Time.current + 1.second, '1', event_1)
        ActiveSupport::Notifications.publish('sql.active_record', Time.current, Time.current + 2.seconds, '2', event_2)
        ActiveSupport::Notifications.publish('sql.active_record', Time.current, Time.current + 3.seconds, '3', event_3)
      end

      expect(subject.results).to match(
        calls: '3 (1 cached)',
        duration: '6000.00ms',
        warnings: ["active-record duration: 6000.0 over 3000"],
        details: contain_exactly(
          a_hash_including(
            cached: '',
            duration: 1000.0,
            sql: 'SELECT * FROM users WHERE id = 10'
          ),
          a_hash_including(
            cached: 'cached',
            duration: 2000.0,
            sql: 'SELECT * FROM users WHERE id = 10'
          ),
          a_hash_including(
            cached: '',
            duration: 3000.0,
            sql: 'UPDATE users SET admin = true WHERE id = 10'
          )
        )
      )
    end
  end

  context 'when database load balancing is enabled' do
    before do
      allow(Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
      allow(Gitlab::Database::LoadBalancing).to receive(:db_role_for_connection).with(connection_replica).and_return(:replica)
      allow(Gitlab::Database::LoadBalancing).to receive(:db_role_for_connection).with(connection_primary).and_return(:primary)
    end

    it 'includes db role data' do
      Timecop.freeze(2021, 2, 23, 10, 0) do
        ActiveSupport::Notifications.publish('sql.active_record', Time.current, Time.current + 1.second, '1', event_1)
        ActiveSupport::Notifications.publish('sql.active_record', Time.current, Time.current + 2.seconds, '2', event_2)
        ActiveSupport::Notifications.publish('sql.active_record', Time.current, Time.current + 3.seconds, '3', event_3)
      end

      expect(subject.results).to match(
        calls: '3 (1 cached)',
        duration: '6000.00ms',
        warnings: ["active-record duration: 6000.0 over 3000"],
        details: contain_exactly(
          a_hash_including(
            cached: '',
            duration: 1000.0,
            sql: 'SELECT * FROM users WHERE id = 10',
            db_role: :primary
          ),
          a_hash_including(
            cached: 'cached',
            duration: 2000.0,
            sql: 'SELECT * FROM users WHERE id = 10',
            db_role: :replica
          ),
          a_hash_including(
            cached: '',
            duration: 3000.0,
            sql: 'UPDATE users SET admin = true WHERE id = 10',
            db_role: :primary
          )
        )
      )
    end
  end
end
