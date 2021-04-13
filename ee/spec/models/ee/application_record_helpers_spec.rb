# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationRecord do
  describe '.with_fast_read_statement_timeout' do
    let(:session) { double(:session) }

    before do
      allow(::Gitlab::Database::LoadBalancing::Session).to receive(:current).and_return(session)
      allow(session).to receive(:fallback_to_replicas_for_ambiguous_queries).and_yield
    end

    it 'yields control' do
      expect do |blk|
        described_class.with_fast_read_statement_timeout(&blk)
      end.to yield_control.once
    end

    context 'when the query runs faster than configured timeout' do
      it 'executes the query without error' do
        result = nil

        expect do
          described_class.with_fast_read_statement_timeout(100) do
            result = described_class.connection.exec_query('SELECT 1')
          end
        end.not_to raise_error

        expect(result).not_to be_nil
      end
    end

    # This query hangs for 10ms and then gets cancelled.  As there is no
    # other way to test the timeout for sure, 10ms of waiting seems to be
    # reasonable!
    context 'when the query runs longer than configured timeout' do
      it 'cancels the query and raiss an exception' do
        expect do
          described_class.with_fast_read_statement_timeout(10) do
            described_class.connection.exec_query('SELECT pg_sleep(0.1)')
          end
        end.to raise_error(ActiveRecord::QueryCanceled)
      end
    end
  end
end
