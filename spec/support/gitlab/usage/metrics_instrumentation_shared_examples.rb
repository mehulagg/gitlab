# frozen_string_literal: true

RSpec.shared_examples 'a correct instrumented metric value' do |options, expected_value|
  let(:time_frame) { options[:time_frame] }
  let(:extra) { options[:extra] }

  before do
    allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(false)
  end

  it 'has correct value' do
    expect(described_class.new(time_frame: time_frame, extra: extra).value).to eq(expected_value)
  end
end
