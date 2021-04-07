# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Pipelines::EpicsPipeline, :clean_gitlab_redis_cache do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:bulk_import) { create(:bulk_import, user: user) }

  let_it_be(:entity) do
    create(
      :bulk_import_entity,
      group: group,
      bulk_import: bulk_import,
      source_full_path: 'source/full/path',
      destination_name: 'My Destination Group',
      destination_namespace: group.full_path
    )
  end

  let_it_be(:tracker) { create(:bulk_import_tracker, entity: entity) }
  let_it_be(:context) { BulkImports::Pipeline::Context.new(tracker) }

  before do
    stub_licensed_features(epics: true)
    group.add_owner(user)
  end

  subject { described_class.new(context) }

  describe '#run' do
    it 'imports group epics into destination group' do
      first_page = extracted_data(has_next_page: true)
      last_page = extracted_data

      allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
        allow(extractor)
          .to receive(:extract)
          .and_return(first_page, last_page)
      end

      expect { subject.run }.to change(::Epic, :count).by(2)
    end
  end

  describe '#load' do
    context 'when user is authorized to create the epic' do
      it 'creates the epic' do
        author = create(:user, email: 'member@email.com')
        parent_epic = create(:epic, group: group)
        child_epic = create(:epic, group: group)
        label = create(:group_label, group: group)
        group.add_developer(author)

        data = {
          'id' => 99,
          'iid' => 99,
          'title' => 'epic',
          'state' => 'opened',
          'confidential' => false,
          'author_id' => author.id,
          'parent' => parent_epic,
          'children' => [child_epic],
          'labels' => [
            label
          ]
        }

        expect { subject.load(context, data) }.to change(::Epic, :count).by(1)

        epic = group.epics.find_by_iid(99)

        expect(epic.group).to eq(group)
        expect(epic.author).to eq(author)
        expect(epic.title).to eq('epic')
        expect(epic.state).to eq('opened')
        expect(epic.confidential).to eq(false)
        expect(epic.parent).to eq(parent_epic)
        expect(epic.children).to contain_exactly(child_epic)
        expect(epic.labels).to contain_exactly(label)
      end
    end

    context 'when user is not authorized to create the epic' do
      before do
        allow(user).to receive(:can?).with(:admin_epic, group).and_return(false)
      end

      it 'raises NotAllowedError' do
        expect { subject.load(context, extracted_data) }
          .to raise_error(::BulkImports::Pipeline::NotAllowedError)
      end
    end
  end

  describe '#transform' do
    it 'caches epic source id in redis' do
      data = { 'id' => 'gid://gitlab/Epic/1', 'iid' => 1 }
      cache_key = "bulk_import:#{bulk_import.id}:entity:#{entity.id}:epic:#{data['iid']}"
      source_params = { source_id: '1' }.to_json

      ::Gitlab::Redis::Cache.with do |redis|
        expect(redis).to receive(:set).with(cache_key, source_params, ex: ::BulkImports::Pipeline::CACHE_KEY_EXPIRATION)
      end

      subject.transform(context, data)
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
            query: EE::BulkImports::Groups::Graphql::GetEpicsQuery
          }
        )
    end

    it 'has transformers' do
      expect(described_class.transformers)
        .to contain_exactly(
          { klass: BulkImports::Common::Transformers::ProhibitedAttributesTransformer, options: nil },
          { klass: BulkImports::Common::Transformers::UserReferenceTransformer, options: { reference: :author } },
          { klass: EE::BulkImports::Groups::Transformers::EpicAttributesTransformer, options: nil }
        )
    end
  end

  def extracted_data(has_next_page: false)
    data = [
      {
        'id' => "gid://gitlab/Epic/99",
        'iid' => has_next_page ? 2 : 1,
        'title' => 'epic1',
        'state' => 'closed',
        'confidential' => true,
        'labels' => {
          'nodes' => []
        }
      }
    ]

    page_info = {
      'has_next_page' => has_next_page,
      'next_page' => has_next_page ? 'cursor' : nil
    }

    BulkImports::Pipeline::ExtractedData.new(data: data, page_info: page_info)
  end
end
