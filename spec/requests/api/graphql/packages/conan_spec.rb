# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'conan package details' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:package) { create(:conan_package, project: project) }

  let(:metadata) { query_graphql_fragment('ConanMetadata') }
  let(:first_file_response_metadata) { graphql_data_at(:package, :package_files, :nodes, 0, :file_metadata)}
  let(:package_files_metadata) {query_graphql_fragment('ConanFileMetadata')}

  it_behaves_like 'a package detail' do
    let(:query) do
      graphql_query_for(:package, { id: package_global_id }, <<~FIELDS)
      #{all_graphql_fields_for('PackageDetailsType', max_depth: depth, excluded: excluded)}
      metadata {
        #{metadata}
      }
      packageFiles {
        nodes {
          #{package_files}
          fileMetadata {
            #{package_files_metadata}
          }
        }
      }
      FIELDS
    end

    it 'has the correct metadata' do
      expect(metadata_response).to include(
        'id' => global_id_of(package.conan_metadatum),
        'recipe' => package.conan_metadatum.recipe,
        'packageChannel' => package.conan_metadatum.package_channel,
        'packageUsername' => package.conan_metadatum.package_username,
        'recipePath' => package.conan_metadatum.recipe_path
      )
    end

    it_behaves_like 'a package with files'

    it 'has the correct file metadata' do
      expect(first_file_response_metadata).to include(
        'id' =>  global_id_of(first_file.conan_file_metadatum),
        'packageRevision' => first_file.conan_file_metadatum.package_revision,
        'conanPackageReference' => first_file.conan_file_metadatum.conan_package_reference,
        'recipeRevision' => first_file.conan_file_metadatum.recipe_revision,
        'conanFileType' => first_file.conan_file_metadatum.conan_file_type.upcase
      )
    end
  end
end
