# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integration do
  describe '.available_services_names' do
    it { expect(described_class.available_services_names).to include('github') }
  end

  describe '.project_specific_services_names' do
    before do
      allow(::Gitlab).to receive(:com?).and_return(com)
    end

    context 'when not on gitlab.com' do
      let(:com) { false }

      it do
        expect(described_class.project_specific_services_names)
          .to include(*described_class::EE_PROJECT_SPECIFIC_INTEGRATION_NAMES)
      end
    end

    context 'when on gitlab.com' do
      let(:com) { true }

      it do
        expect(described_class.project_specific_services_names)
          .to include(*described_class::EE_PROJECT_SPECIFIC_INTEGRATION_NAMES, *Integration::EE_COM_PROJECT_SPECIFIC_INTEGRATION_NAMES)
      end
    end
  end
end
