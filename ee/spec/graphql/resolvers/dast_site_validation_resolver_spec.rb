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

  before do
    project.add_maintainer(current_user)
  end

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::DastSiteValidationType.connection_type)
  end

  context 'when resolving a single DAST site validation' do
    subject { sync(single_dast_site_validation(target_url: target_url)) }

    it { is_expected.to contain_exactly(dast_site_validation1) }
  end

  context 'when resolving multiple DAST site validations' do
    subject { sync(dast_site_validations) }

    it { is_expected.to contain_exactly(dast_site_validation2, dast_site_validation1) }

    context 'when filtering by normalized_target_url' do
      subject { sync(dast_site_validations(normalized_target_url: dast_site_validation2.url_base)) }

      it { is_expected.to contain_exactly(dast_site_validation2) }
    end
  end

  private

  def dast_site_validations(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end

  def single_dast_site_validation(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
