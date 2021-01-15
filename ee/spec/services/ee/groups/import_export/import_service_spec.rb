# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::ImportExport::ImportService do
  let_it_be(:import_file) { fixture_file_upload('spec/fixtures/group_export.tar.gz') }
  let_it_be(:user) { create(:user) }
  let_it_be(:group) do
    create(:group, :wiki_repo).tap do |g|
      g.add_owner(user)
    end
  end

  subject(:import_service) { described_class.new(group: group, user: user) }

  before do
    ImportExportUpload.create!(group: group, import_file: import_file)
  end

  context 'when group_wikis feature is enabled' do
    it 'calls the group wiki restorer' do
      stub_licensed_features(group_wikis: true)

      expect_next_instance_of(
        ::Gitlab::ImportExport::RepoRestorer,
        path_to_bundle: /#{::Gitlab::ImportExport.group_wiki_repo_bundle_filename}/,
        shared: instance_of(Gitlab::ImportExport::Shared),
        importable: instance_of(GroupWiki)
      ) do |restorer|
        expect(restorer).to receive(:restore).and_return(true)
      end

      import_service.execute
    end
  end

  context 'when group_wikis feature is not enabled' do
    it 'does not call the group wiki restorer' do
      expect(::Gitlab::ImportExport::RepoRestorer).not_to receive(:new)

      expect { import_service.execute }.not_to raise_error(Gitlab::ImportExport::Error)
    end
  end
end
