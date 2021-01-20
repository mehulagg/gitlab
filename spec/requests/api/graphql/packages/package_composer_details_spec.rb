# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'package details' do
  using RSpec::Parameterized::TableSyntax
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:package) { create(:composer_package, project: project) }
  let_it_be(:composer_json) { { name: 'name', type: 'type', license: 'license', version: 1 } }
  let_it_be(:composer_metadatum) do
    # we are forced to manually create the metadatum, without using the factory to force the sha to be a string
    # and avoid an error where gitaly can't find the repository
    create(:composer_metadatum, package: package, target_sha: 'foo_sha', composer_json: composer_json)
  end

  let(:depth) { 3 }

  let(:query) do
    graphql_query_for(:package_details, { id: package_global_id }, <<~FIELDS)
    ... on PackageComposerDetails {
      #{all_graphql_fields_for('PackageComposerDetails', max_depth: depth)}
    }
    FIELDS
  end

  let(:user) { project.owner }
  let(:package_global_id) { global_id_of(package) }
  let(:package_details) { graphql_data_at(:package_details) }

  subject { post_graphql(query, current_user: user) }

  it_behaves_like 'a working graphql query' do
    before do
      subject
    end

    it 'matches the JSON schema' do
      expect(package_details).to match_schema('graphql/packages/package_composer_details')
    end

    it 'includes the fields of the correct package' do
      expect(package_details).to include(
        'id' => package_global_id,
        'composerMetadatum' => {
          'targetSha' => 'foo_sha',
          'composerJson' => composer_json.transform_keys(&:to_s).transform_values(&:to_s)
        }
      )
    end
  end

  # NB: there is a bad N+1 problem here!
  context 'there are other versions of this package' do
    let_it_be(:siblings) { create_list(:composer_package, 2, project: project, name: package.name) }

    it 'includes the sibling versions' do
      subject

      expect(graphql_data_at(:package_details, :versions, :nodes)).to match_array(
        siblings.map { |p| a_hash_including('id' => global_id_of(p)) }
      )
    end
  end
end
