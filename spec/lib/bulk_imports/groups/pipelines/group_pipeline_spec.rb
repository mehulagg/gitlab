# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Groups::Pipelines::GroupPipeline do
  describe '#run' do
    let(:user) { create(:user) }
    let(:parent) { create(:group) }
    let(:bulk_import) { create(:bulk_import, user: user) }
    let(:entity) do
      create(
        :bulk_import_entity,
        bulk_import: bulk_import,
        source_full_path: 'source/full/path',
        destination_name: 'My Destination Group',
        destination_namespace: parent.full_path
      )
    end

    let(:context) { BulkImports::Pipeline::Context.new(entity) }

    let(:group_data) do
      {
        'data' => {
          'group' => {
            'name' => 'source_name',
            'fullPath' => 'source/full/path',
            'visibility' => 'private',
            'projectCreationLevel' => 'developer',
            'subgroupCreationLevel' => 'maintainer',
            'description' => 'Group Description',
            'emailsDisabled' => true,
            'lfsEnabled' => false,
            'mentionsDisabled' => true
          }
        }
      }
    end

    before do
      allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
        allow(extractor).to receive(:extract).and_return([group_data])
      end

      parent.add_owner(user)
    end

    it 'imports new group into destination group' do
      group_path = 'my-destination-group'

      subject.run(context)

      imported_group = Group.find_by_path(group_path)

      expect(imported_group).not_to be_nil
      expect(imported_group.parent).to eq(parent)
      expect(imported_group.path).to eq(group_path)
      expect(imported_group.description).to eq(group_data.dig('data', 'group', 'description'))
      expect(imported_group.visibility).to eq(group_data.dig('data', 'group', 'visibility'))
      expect(imported_group.project_creation_level).to eq(Gitlab::Access.project_creation_string_options[group_data.dig('data', 'group', 'projectCreationLevel')])
      expect(imported_group.subgroup_creation_level).to eq(Gitlab::Access.subgroup_creation_string_options[group_data.dig('data', 'group', 'subgroupCreationLevel')])
      expect(imported_group.lfs_enabled?).to eq(group_data.dig('data', 'group', 'lfsEnabled'))
      expect(imported_group.emails_disabled?).to eq(group_data.dig('data', 'group', 'emailsDisabled'))
      expect(imported_group.mentions_disabled?).to eq(group_data.dig('data', 'group', 'mentionsDisabled'))
    end
  end

  describe 'pipeline parts' do
    it { expect(described_class).to include_module(BulkImports::Pipeline) }
    it { expect(described_class).to include_module(BulkImports::Pipeline::Runner) }

    it 'has extractors' do
      expect(described_class.get_extractor)
        .to eq(
          klass: BulkImports::Common::Extractors::GraphqlExtractor,
          options: {
            query: BulkImports::Groups::Graphql::GetGroupQuery
          }
        )
    end

    it 'has transformers' do
      expect(described_class.transformers)
        .to contain_exactly(
          { klass: BulkImports::Common::Transformers::HashKeyDigger, options: { key_path: %w[data group] } },
          { klass: BulkImports::Common::Transformers::UnderscorifyKeysTransformer, options: nil },
          { klass: BulkImports::Common::Transformers::ProhibitedAttributesTransformer, options: nil },
          { klass: BulkImports::Groups::Transformers::GroupAttributesTransformer, options: nil }
        )
    end

    it 'has loaders' do
      expect(described_class.get_loader).to eq(klass: BulkImports::Groups::Loaders::GroupLoader, options: nil)
    end
  end
end
