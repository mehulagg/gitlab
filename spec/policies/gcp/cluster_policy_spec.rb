require 'spec_helper'

describe Gcp::ClusterPolicy, :models do
  set(:project) { create(:project) }
  set(:cluster) { create(:gcp_cluster, project: project) }
  let(:user) { create(:user) }
  let(:policy) { described_class.new(user, cluster) }

  describe 'rules' do
    context 'when developer' do
      before do
        project.add_developer(user)
      end

      it { expect(policy).to be_disallowed :update_cluster }
      it { expect(policy).to be_disallowed :admin_cluster }
    end

    context 'when master' do
      before do
        project.add_master(user)
      end

      it { expect(policy).to be_allowed :update_cluster }
      it { expect(policy).to be_allowed :admin_cluster }
    end
  end
end
