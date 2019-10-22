# frozen_string_literal: true

# This spec is a lightweight version of 2 specs:
#   * project_tree_restorer_spec.rb
#   * group_tree_restorer_spec.rb
#
# In depth testing is being done in the above specs.
# This spec tests that restore project works for both
# group and project but does not have 100% relation coverage.

require 'spec_helper'

describe Gitlab::ImportExport::RelationTreeRestorer do
  include ImportExport::CommonUtil

  let(:user) { create(:user) }
  let(:shared) { Gitlab::ImportExport::Shared.new(importable) }
  let(:members_mapper) { Gitlab::ImportExport::MembersMapper.new(exported_members: {}, user: user, importable: importable) }

  let(:importable_hash) do
    json = IO.read(path)
    ActiveSupport::JSON.decode(json)
  end

  let(:relation_tree_restorer) do
    described_class.new(
      user:             user,
      shared:           shared,
      tree_hash:        tree_hash,
      importable:       importable,
      object_builder:   object_builder,
      members_mapper:   members_mapper,
      relation_factory: relation_factory,
      reader:           reader
    )
  end

  subject { relation_tree_restorer.restore }

  context 'when restoring a project' do
    let(:path) { 'spec/fixtures/lib/gitlab/import_export/complex/project.json' }
    let(:importable) { create(:project, :builds_enabled, :issues_disabled, name: 'project', path: 'project') }
    let(:object_builder) { Gitlab::ImportExport::GroupProjectObjectBuilder }
    let(:relation_factory) { Gitlab::ImportExport::ProjectRelationFactory }
    let(:reader) { Gitlab::ImportExport::Reader.new(shared: shared) }
    let(:tree_hash) { importable_hash }

    it 'restores project tree' do
      expect(subject).to eq(true)
    end

    describe 'imported project' do
      let(:project) { Project.find_by_path('project') }

      before do
        subject
      end

      it 'has the project attributes and relations' do
        expect(project.description).to eq('Nisi et repellendus ut enim quo accusamus vel magnam.')
        expect(project.labels.count).to eq(3)
        expect(project.boards.count).to eq(1)
        expect(project.project_feature).not_to be_nil
        expect(project.custom_attributes.count).to eq(2)
        expect(project.project_badges.count).to eq(2)
        expect(project.snippets.count).to eq(1)
      end
    end
  end

  context 'when restoring a group' do
    let(:path) { 'spec/fixtures/lib/gitlab/import_export/group_exports/no_children/group.json' }
    let(:importable) { create(:group) }
    let(:relation_factory) { Gitlab::ImportExport::GroupRelationFactory }
    let(:object_builder) { Gitlab::ImportExport::GroupObjectBuilder }
    let(:tree_hash) { importable_hash.except('members') }

    let(:reader) do
      Gitlab::ImportExport::Reader.new(
        shared: shared,
        config: Gitlab::ImportExport::Config.new(
          config: Gitlab::ImportExport.group_config_file
        ).to_h
      )
    end

    it 'restores group tree' do
      expect(subject).to eq(true)
    end

    describe 'imported group' do
      let(:group) { Group.find_by_name('group') }

      before do
        subject
      end

      it 'has the group attributes and relations' do
        expect(group.description).to eq('Group Description')
        expect(group.labels.count).to eq(10)
        expect(group.boards.count).to eq(2)
        expect(group.badges.count).to eq(1)
        expect(group.milestones.count).to eq(5)
      end
    end
  end
end
