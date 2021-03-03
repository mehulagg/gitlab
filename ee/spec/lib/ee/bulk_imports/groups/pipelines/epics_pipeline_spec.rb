# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Pipelines::EpicsPipeline, :clean_gitlab_redis_cache do
  let_it_be(:cursor) { 'cursor' }
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
      first_page = extractor_data(has_next_page: true, cursor: cursor)
      last_page = extractor_data(has_next_page: false, page: 2)

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
        data = extractor_data(has_next_page: false)

        expect { subject.load(context, data) }.to raise_error(::BulkImports::Pipeline::NotAllowedError)
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

  describe '#after_run' do
    context 'when extracted data has next page' do
      it 'updates tracker information and runs pipeline again' do
        data = extractor_data(has_next_page: true, cursor: cursor)

        expect(subject).to receive(:run)

        subject.after_run(data)

        expect(tracker.has_next_page).to eq(true)
        expect(tracker.next_page).to eq(cursor)
      end
    end

    context 'when extracted data has no next page' do
      it 'updates tracker information and does not run pipeline' do
        data = extractor_data(has_next_page: false)

        expect(subject).not_to receive(:run)

        subject.after_run(data)

        expect(tracker.has_next_page).to eq(false)
        expect(tracker.next_page).to be_nil
      end
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
          { klass: EE::BulkImports::Groups::Transformers::EpicAttributesTransformer, options: nil }
        )
    end
  end

  def extractor_data(has_next_page:, cursor: nil, page: 1)
    data = [
      {
        'id' => "gid://gitlab/Epic/#{page}",
        'iid' => page,
        'title' => 'epic1',
        'state' => 'closed',
        'confidential' => true,
        'labels' => {
          'nodes' => []
        }
      }
    ]

    page_info = {
      'end_cursor' => cursor,
      'has_next_page' => has_next_page
    }

    BulkImports::Pipeline::ExtractedData.new(data: data, page_info: page_info)
  end
end
