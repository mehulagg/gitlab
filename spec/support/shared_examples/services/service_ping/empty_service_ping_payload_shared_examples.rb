# frozen_string_literal: true

RSpec.shared_examples 'empty service ping payload' do
  it { is_expected.to eq({}) }
end
