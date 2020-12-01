# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::DastSiteValidationResolver do
  include GraphqlHelpers

  let_it_be(:target_url) { generate(:url) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:dast_site_token) { create(:dast_site_token, project: project, url: target_url) }
  let_it_be(:dast_site_validation) { create(:dast_site_validation, dast_site_token: dast_site_token) }

  subject { sync(resolve_dast_site_validations(target_url: target_url)) }

  before do
    project.add_maintainer(current_user)
  end

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::DastSiteValidationType.connection_type)
  end

  it 'returns DAST site validation' do
    is_expected.to eq(dast_site_validation)
  end

  private

  def resolve_dast_site_validations(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
