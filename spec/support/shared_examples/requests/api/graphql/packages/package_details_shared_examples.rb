# frozen_string_literal: true

RSpec.shared_examples 'a package detail' do
  include GraphqlHelpers

  let(:package_global_id) { global_id_of(package) }
  let(:depth) { 3 }
  let(:excluded) { %w[metadata apiFuzzingCiConfiguration pipeline packageFiles] }
  let(:package_files) { all_graphql_fields_for('PackageFile') }
  let(:user) { project.owner }
  let(:package_details) { graphql_data_at(:package) }
  let(:metadata_response) { graphql_data_at(:package, :metadata) }
  let(:first_file) { package.package_files.find { |f| global_id_of(f) == first_file_response['id'] } }
  let(:package_files_response) { graphql_data_at(:package, :package_files, :nodes) }
  let(:first_file_response) { graphql_data_at(:package, :package_files, :nodes, 0)}

  let(:query) do
    graphql_query_for(:package, { id: package_global_id }, <<~FIELDS)
    #{all_graphql_fields_for('PackageDetailsType', max_depth: depth, excluded: excluded)}
    metadata {
      #{metadata}
    }
    packageFiles {
      nodes {
        #{package_files}
      }
    }
    FIELDS
  end

  subject { post_graphql(query, current_user: user) }

  before do
    subject
  end

  it_behaves_like 'a working graphql query' do
    it 'matches the JSON schema' do
      expect(package_details).to match_schema('graphql/packages/package_details')
    end
  end
end

RSpec.shared_examples 'a package with files' do
  include GraphqlHelpers

  it 'has the right amount of files' do
    expect(package_files_response.length).to be(package.package_files.length)
  end

  it 'has the basic package files data' do
    expect(first_file_response).to include(
      'id' => global_id_of(first_file),
      'fileName' => first_file.file_name,
      'size' => first_file.size.to_s,
      'downloadPath' => first_file.download_path,
      'fileSha1' => first_file.file_sha1,
      'fileMd5' => first_file.file_md5,
      'fileSha256' => first_file.file_sha256
    )
  end
end
