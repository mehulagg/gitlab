# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::AppSec::Dast::ProfileResolver do
  include GraphqlHelpers

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user, developer_projects: [project]) }
  let_it_be(:dast_profile1) { create(:dast_profile, project: project) }
  let_it_be(:dast_profile2) { create(:dast_profile, project: project) }

  let(:current_user) { developer }

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::Dast::ProfileType.connection_type)
  end

  context 'when resolving multiple DAST profiles' do
    subject { sync(dast_profiles) }

    it { is_expected.to contain_exactly(dast_profile1, dast_profile2) }

    context 'when the feature is disabled' do
      before do
        stub_licensed_features(security_on_demand_scans: false)
      end

      it { is_expected.to be_empty }
    end

    context 'when the user does not have access' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_empty }
    end
  end

  private

  def dast_profiles
    resolve(described_class, obj: project, ctx: { current_user: current_user })
  end
end
