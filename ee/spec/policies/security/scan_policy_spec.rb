# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::ScanPolicy do
  describe 'read_scan' do
    let_it_be(:user) { create(:user) }
    let_it_be(:scan) { create(:security_scan) }
    let_it_be(:project) { scan.project }

    subject { described_class.new(user, scan) }

    context 'when the security_dashboard feature is enabled' do
      before do
        stub_licensed_features(security_dashboard: true)
      end

      context "when the current user has developer access to the scan's project" do
        before do
          project.add_developer(user)
        end

        it { is_expected.to be_allowed(:read_scan) }
      end

      context "when the current user does not have developer access to the scan's project" do
        it { is_expected.to be_disallowed(:read_scan) }
      end
    end

    context 'when the security_dashboard feature is disabled' do
      before do
        stub_licensed_features(security_dashboard: false)

        project.add_developer(user)
      end

      it { is_expected.to be_disallowed(:read_scan) }
    end
  end
end
