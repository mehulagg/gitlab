# frozen_string_literal: true

RSpec.shared_examples 'having health status' do
  context 'validations' do
    it do
      is_expected.to define_enum_for(:health_status)
        .with_values(on_track: 1, needs_attention: 2, at_risk: 3)
    end

    it { is_expected.to allow_value(nil).for(:health_status) }
  end
end
