# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline do
  let_it_be(:cursor) { 'cursor' }
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:epic) { create(:epic, group: group) }
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

  describe '#initialize' do
    it 'update context with next epic iid' do
      subject

      expect(context.extra[:epic_iid]).to eq(epic.iid)
    end
  end

  describe '#run' do
    it 'imports epic award emoji' do
      data = extractor_data(has_next_page: false)

      allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
        allow(extractor)
          .to receive(:extract)
          .and_return(data)
      end

      expect { subject.run }.to change(::AwardEmoji, :count).by(1)
      expect(epic.award_emoji.first.name).to eq('thumbsup')
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

      it 'updates context with next epic iid' do
        epic2 = create(:epic, group: group)
        data = extractor_data(has_next_page: false)

        expect(subject).to receive(:run)

        subject.after_run(data)

        expect(context.extra[:epic_iid]).to eq(epic2.iid)
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
            query: EE::BulkImports::Groups::Graphql::GetEpicAwardEmojiQuery
          }
        )
    end

    it 'has transformers' do
      expect(described_class.transformers)
        .to contain_exactly(
          { klass: BulkImports::Common::Transformers::ProhibitedAttributesTransformer, options: nil },
          { klass: BulkImports::Common::Transformers::UserReferenceTransformer, options: nil }
        )
    end

    it 'has loaders' do
      expect(described_class.get_loader).to eq(klass: EE::BulkImports::Groups::Loaders::EpicAwardEmojiLoader, options: nil)
    end
  end

  def extractor_data(has_next_page:, cursor: nil)
    data = [{ 'name' => 'thumbsup' }]

    page_info = {
      'end_cursor' => cursor,
      'has_next_page' => has_next_page
    }

    BulkImports::Pipeline::ExtractedData.new(data: data, page_info: page_info)
  end
end
