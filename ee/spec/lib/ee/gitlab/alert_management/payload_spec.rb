# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::Payload do
  describe '#parse' do
    let_it_be(:project) { build_stubbed(:project) }

    let(:payload) { {} }

    context 'with the payload specifing cilium as monitoring tool' do
      before do
        stub_licensed_features(cilium_alerts: true)
      end
      subject { described_class.parse(project, payload) }

      context 'with the payload specifying an unknown tool' do
        let(:payload) { { 'monitoring_tool' => 'Cilium' } }

        it { is_expected.to be_a Gitlab::AlertManagement::Payload::Cilium }
      end
    end
  end
end
