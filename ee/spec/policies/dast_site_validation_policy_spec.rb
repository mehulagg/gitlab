# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidationPolicy do
  describe 'create_on_demand_dast_scan' do
    let_it_be(:dast_site_validation, reload: true) { create(:dast_site_validation) }
    let_it_be(:project) { dast_site_validation.dast_site_token.project }
    let_it_be(:user) { create(:user) }

    subject { described_class.new(user, dast_site_validation) }

    before do
      stub_licensed_features(security_on_demand_scans: true)
    end

    context 'when a user does not have access to the project' do
      it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
    end

    context 'when a user does not have access to dast_site_validations' do
      before do
        project.add_guest(user)
      end

      it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
    end

    context 'when a user has access dast_site_validations' do
      before do
        project.add_developer(user)
      end

      it { is_expected.to be_allowed(:create_on_demand_dast_scan) }

      context 'when on demand scan licensed feature is not available' do
        before do
          stub_licensed_features(security_on_demand_scans: false)
        end

        it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
      end
    end
  end
end
