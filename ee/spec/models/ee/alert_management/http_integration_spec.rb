# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::HttpIntegration do
  subject(:integration) { create(:alert_management_http_integration) }

  describe 'validations' do
    context 'with valid license' do
      before do
        stub_licensed_features(multiple_alert_http_integrations: true)
      end

      it { is_expected.not_to validate_uniqueness_of(:project) }
    end

    context 'without license' do
      it { is_expected.to validate_uniqueness_of(:project) }
    end
  end
end
