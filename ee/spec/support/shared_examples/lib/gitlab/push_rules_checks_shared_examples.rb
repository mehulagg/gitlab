# frozen_string_literal: true

RSpec.shared_examples 'check ignored when push rule unlicensed' do
  before do
    stub_licensed_features(push_rules: false)
  end

  it { is_expected.to be_truthy }
end
