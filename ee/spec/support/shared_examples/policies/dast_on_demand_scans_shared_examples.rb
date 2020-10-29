# frozen_string_literal: true

RSpec.shared_examples 'a dast on-demand scan policy' do
  let(:group) { create(:group) }
  let(:project) { create(:project, group: group) }
  let(:user) { create(:user) }

  subject { described_class.new(user, record) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe 'create_on_demand_dast_scan' do
    context 'when a user does not have access to the project' do
      it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
    end

    context 'when the user is a guest' do
      before do
        project.add_guest(user)
      end

      it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
    end

    context 'when the user is a developer' do
      before do
        project.add_developer(user)
      end

      it { is_expected.to be_allowed(:create_on_demand_dast_scan) }
    end

    context 'when the user is a maintainer' do
      before do
        project.add_maintainer(user)
      end

      it { is_expected.to be_allowed(:create_on_demand_dast_scan) }
    end

    context 'when the user is an owner' do
      before do
        group.add_owner(user)
      end

      it { is_expected.to be_allowed(:create_on_demand_dast_scan) }
    end

    context 'when the user is allowed' do
      before do
        project.add_developer(user)
      end

      context 'when on demand scan licensed feature is not available' do
        before do
          stub_licensed_features(security_on_demand_scans: false)
        end

        it { is_expected.to be_disallowed(:create_on_demand_dast_scan) }
      end
    end
  end
end
