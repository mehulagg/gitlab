# frozen_string_literal: true

RSpec.shared_examples 'returning an error service response' do |message:|
  it 'returns an error' do
    result = subject

    expect(result).to be_error

    if message
      expect(result.message).to eq(message)
    end
  end
end
