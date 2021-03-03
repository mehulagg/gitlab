# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::DastSiteValidationResolver do
  include GraphqlHelpers

  let_it_be(:target_url) { generate(:url) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:dast_site_token1) { create(:dast_site_token, project: project, url: target_url) }
  let_it_be(:dast_site_validation1) { create(:dast_site_validation, dast_site_token: dast_site_token1) }
  let_it_be(:dast_site_token2) { create(:dast_site_token, project: project, url: generate(:url)) }
  let_it_be(:dast_site_validation2) { create(:dast_site_validation, dast_site_token: dast_site_token2) }
  let_it_be(:dast_site_token3) { create(:dast_site_token, project: project, url: generate(:url)) }
  let_it_be(:dast_site_validation3) { create(:dast_site_validation, dast_site_token: dast_site_token3) }

  before do
    project.add_maintainer(current_user)
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::DastSiteValidationType.connection_type)
  end

  context 'when resolving multiple DAST site validations' do
    subject { dast_site_validations(**args) }

    let(:args) { {} }

    it { is_expected.to contain_exactly(dast_site_validation3, dast_site_validation2, dast_site_validation1) }

    context 'when multiple normalized_target_urls are specified' do
      let(:args) { { normalized_target_urls: [dast_site_validation1.url_base, dast_site_validation3.url_base] } }

      it { is_expected.to contain_exactly(dast_site_validation3, dast_site_validation1) }
    end

    context 'when one normalized_target_url is specified' do
      let(:args) { { normalized_target_urls: [dast_site_validation2.url_base] } }

      it { is_expected.to contain_exactly(dast_site_validation2) }
    end

    context 'when an empty array is specified' do
      let(:args) { { normalized_target_urls: [] } }

      it { is_expected.to be_empty }
    end
  end

  private

  def dast_site_validations(**args)
    context = { current_user: current_user }
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
