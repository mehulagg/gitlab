# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Pipelines::EpicsPipeline do
  let(:cursor) { 'cursor' }
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:bulk_import) { create(:bulk_import, user: user) }
  let(:entity) do
    create(
      :bulk_import_entity,
      group: group,
      bulk_import: bulk_import,
      source_full_path: 'source/full/path',
      destination_name: 'My Destination Group',
      destination_namespace: group.full_path
    )
  end

  let(:context) { BulkImports::Pipeline::Context.new(entity) }

  before do
    stub_licensed_features(epics: true)
    group.add_owner(user)
  end

  subject { described_class.new(context) }

  describe '#run' do
    it 'imports group epics into destination group' do
      first_page = extractor_data(has_next_page: true, cursor: cursor)
      last_page = extractor_data(has_next_page: false)

      allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
        allow(extractor)
          .to receive(:extract)
          .and_return(first_page, last_page)
      end

      expect { subject.run }.to change(::Epic, :count).by(2)
    end
  end

  describe '#after_run' do
    context 'when extracted data has next page' do
      it 'updates tracker information and runs pipeline again' do
        data = extractor_data(has_next_page: true, cursor: cursor)

        expect(subject).to receive(:run)

        subject.after_run(data)

        tracker = entity.trackers.find_by(relation: :epics)

        expect(tracker.has_next_page).to eq(true)
        expect(tracker.next_page).to eq(cursor)
      end
    end

    context 'when extracted data has no next page' do
      it 'updates tracker information and does not run pipeline' do
        data = extractor_data(has_next_page: false)

        expect(subject).not_to receive(:run)

        subject.after_run(data)

        tracker = entity.trackers.find_by(relation: :epics)

        expect(tracker.has_next_page).to eq(false)
        expect(tracker.next_page).to be_nil
      end
    end
  end

  describe '#load' do
    it 'creates the epic' do
      parent_epic = create(:epic, group: group)
      child_epic = create(:epic, group: group)
      label = create(:group_label, group: group)
      bulk_import = create(:bulk_import, user: user)
      entity = create(:bulk_import_entity, bulk_import: bulk_import, group: group)
      context = BulkImports::Pipeline::Context.new(entity)

      data = {
        'title' => 'epic',
        'state' => 'opened',
        'confidential' => false,
        'iid' => 99,
        'author_id' => user.id,
        'group_id' => group.id,
        'parent' => parent_epic,
        'children' => [child_epic],
        'labels' => [
          label
        ]
      }

      expect { subject.load(context, data) }.to change(::Epic, :count).by(1)

      epic = group.epics.last
      expect(epic.group).to eq(group)
      expect(epic.author).to eq(user)
      expect(epic.title).to eq('epic')
      expect(epic.state).to eq('opened')
      expect(epic.confidential).to eq(false)
      expect(epic.iid).to eq(99)
      expect(epic.parent).to eq(parent_epic)
      expect(epic.children).to contain_exactly(child_epic)
      expect(epic.labels).to contain_exactly(label)
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

  def extractor_data(has_next_page:, cursor: nil)
    data = [
      {
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
