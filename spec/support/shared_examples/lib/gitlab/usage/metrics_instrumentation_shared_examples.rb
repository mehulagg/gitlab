# frozen_string_literal: true

RSpec.shared_examples 'a correct instrumented metric value' do |expected_value|
  before do
    allow(ActiveRecord::Base.connection).to receive(:transaction_open?).and_return(false)
  end

  it 'has correct value' do
    expect(subject.value).to eq(expected_value)
  end
end
