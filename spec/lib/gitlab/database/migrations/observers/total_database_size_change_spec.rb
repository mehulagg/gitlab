# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Gitlab::Database::Migrations::Observers::TotalDatabaseSizeChange do
  subject { described_class.new }

  let(:observation) { Gitlab::Database::Migrations::Observation.new }
  let(:connection) { ActiveRecord::Base.connection }

  it 'records the size change' do
    query = 'select pg_database_size(current_database())'
    expect(connection).to receive(:execute).with(query).once.and_return([{ 'pg_database_size' => 1024 }])
    expect(connection).to receive(:execute).with(query).once.and_return([{ 'pg_database_size' => 256 }])

    subject.before
    subject.after
    subject.record(observation)

    expect(observation.total_database_size_change).to eq(256 - 1024)
  end
end
