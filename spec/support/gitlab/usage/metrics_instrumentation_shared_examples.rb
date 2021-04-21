# frozen_string_literal: true

RSpec.shared_examples 'a correct instrumented metric value' do |options, expected_value|
  let(:time_constraints) { ::Gitlab::Usage::Metrics::Instrumentations::Shared::TimeConstraint.new(options[:time_frame], options[:data_source]).build }

  before do
    allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(false)
  end

  it 'has correct value' do
    expect(described_class.new(time_constraints: time_constraints).value).to eq(expected_value)
  end
end
