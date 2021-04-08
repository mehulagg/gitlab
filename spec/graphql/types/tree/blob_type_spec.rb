# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Tree::BlobType do
  specify { expect(described_class.graphql_name).to eq('Blob') }

  specify do
    expect(described_class).to have_graphql_fields(
      :id,
      :sha,
      :name,
      :type,
      :path,
      :flat_path,
      :web_url,
      :web_path,
      :lfs_oid,
      :mode,
      :size,
      :raw_size,
      :raw_blob,
      :file_type,
      :too_large,
      :edit_blob_path,
      :ide_edit_path,
      :stored_externally,
      :raw_path,
      :external_storage_url,
      :replace_path,
      :delete_path,
      :can_modify_blob,
      :fork_path,
      :simple_viewer,
      :rich_viewer
    )
  end
end
