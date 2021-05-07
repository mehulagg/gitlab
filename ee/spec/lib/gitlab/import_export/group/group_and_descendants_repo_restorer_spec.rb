# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ImportExport::Group::GroupAndDescendantsRepoRestorer do
  let_it_be_with_refind(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }

  let(:shared) { Gitlab::ImportExport::Shared.new(group) }
  let(:tree_restorer) { instance_double(Gitlab::ImportExport::Group::TreeRestorer) }
  let(:groups_mapping) { { 100 => group, 200 => subgroup } }

  subject { described_class.new(group: group, shared: shared, tree_restorer: tree_restorer) }

  before do
    allow(tree_restorer).to receive(:groups_mapping).and_return(groups_mapping)
  end

  context 'when group wiki license feature is enabled' do
    before do
      stub_licensed_features(group_wikis: true)
    end

    it 'imports the group and subgroups wiki repo and returns true' do
      group_bundle_path = Gitlab::ImportExport.group_wiki_repo_bundle_full_path(shared, 100)
      expect_next_instance_of(Gitlab::ImportExport::RepoRestorer, importable: group.wiki, shared: shared, path_to_bundle: group_bundle_path) do |restorer|
        expect(restorer).to receive(:restore).and_return(true)
      end

      subgroup_bundle_path = Gitlab::ImportExport.group_wiki_repo_bundle_full_path(shared, 200)
      expect_next_instance_of(Gitlab::ImportExport::RepoRestorer, importable: subgroup.wiki, shared: shared, path_to_bundle: subgroup_bundle_path) do |restorer|
        expect(restorer).to receive(:restore).and_return(true)
      end

      expect(subject.restore).to eq true
    end

    context 'if any of the wiki imports fails' do
      it 'returns false and stops importing other groups' do
        expect_next_instance_of(Gitlab::ImportExport::RepoRestorer, hash_including(importable: group.wiki)) do |restorer|
          expect(restorer).to receive(:restore).and_return(false)
        end

        expect(Gitlab::ImportExport::RepoRestorer).not_to receive(:new).with(hash_including(importable: subgroup.wiki))

        expect(subject.restore).to eq false
      end
    end

    context 'when group is not inside group mappings' do
      let(:groups_mapping) { { 100 => group } }

      it 'avoids calling the restorer, continue importing, and returns true' do
        expect(Gitlab::ImportExport::RepoRestorer).to receive(:new).and_call_original
        expect(Gitlab::ImportExport::RepoRestorer).not_to receive(:new).with(hash_including(importable: subgroup.wiki))

        expect(subject.restore).to eq true
      end
    end

    context 'when group mapping is empty' do
      let(:groups_mapping) { {} }

      it 'does not try to import wikis and returns true' do
        expect(Gitlab::ImportExport::RepoRestorer).not_to receive(:new)

        expect(subject.restore).to eq true
      end
    end
  end

  context 'when group wiki license feature is not enabled' do
    it 'does not try to import wikis and returns true' do
      stub_licensed_features(group_wikis: false)

      expect(Gitlab::ImportExport::RepoRestorer).not_to receive(:new)

      expect(subject.restore).to eq true
    end
  end
end
