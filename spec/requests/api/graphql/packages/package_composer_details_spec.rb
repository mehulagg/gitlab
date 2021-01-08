# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'package composer details' do
  using RSpec::Parameterized::TableSyntax
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:package) { create(:composer_package, :with_metadatum, project: project) }

  let(:query) do
    graphql_query_for(
      'packageComposerDetails',
      { id: package_global_id },
      all_graphql_fields_for('PackageComposerDetails')
    )
  end

  let(:user) { project.owner }
  let(:package_global_id) { package.to_global_id.to_s }
  let(:package_composer_details_response) { graphql_data.dig('packageComposerDetails') }

  subject { post_graphql(query, current_user: user) }

  it_behaves_like 'a working graphql query' do
    before do
      subject
    end

    it 'matches the JSON schema' do
      expect(package_composer_details_response).to match_schema('graphql/packages/package_composer_details')
    end
  end
end
