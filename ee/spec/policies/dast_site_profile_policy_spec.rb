# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteProfilePolicy do
  describe 'create_on_demand_dast_scan' do
    let(:dast_site_profile) { create(:dast_site_profile) }
    let(:project) { dast_site_profile.project }
    let(:user) { create(:user) }

    subject { described_class.new(user, dast_site_profile) }

    before do
      stub_licensed_features(security_on_demand_scans: true)
    end

    context 'when a user does not have access to the project' do
      it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
    end

    context 'when a user does not have access to dast_site_profiles' do
      before do
        project.add_guest(user)
      end

      it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
    end

    context 'when a user has access dast_site_profiles' do
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
