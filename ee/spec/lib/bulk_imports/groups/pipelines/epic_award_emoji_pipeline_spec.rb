# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline do
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
      allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
        allow(extractor)
          .to receive(:extract)
          .and_return(extracted_data)
      end

      expect { subject.run }.to change(::AwardEmoji, :count).by(1)
      expect(epic.award_emoji.first.name).to eq('thumbsup')
    end

    context 'when extracted data many pages' do
      it 'runs pipeline for the second page' do
        first_page = extracted_data(has_next_page: true)
        last_page = extracted_data

        allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
          allow(extractor)
            .to receive(:extract)
            .and_return(first_page, last_page)
        end

        subject.run
      end
    end

    context 'when there is many epics to import' do
      let_it_be(:second_epic) { create(:epic, group: group) }

      it 'runs the pipeline for the next epic' do
        allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
          allow(extractor)
            .to receive(:extract)
            .twice # for each epic
            .and_return(extracted_data)
        end

        expect(context.extra)
          .to receive(:[]=)
          .with(:epic_iid, epic.iid)
          .and_call_original
        expect(context.extra)
          .to receive(:[]=)
          .with(:epic_iid, second_epic.iid)
          .and_call_original
        expect(context.extra)
          .to receive(:[]=)
          .with(:epic_iid, nil)
          .and_call_original

        subject.run
      end
    end
  end

  describe '#load' do
    let(:data) { { 'name' => 'thumbsup', 'user_id' => user.id } }

    context 'when emoji does not exist' do
      it 'creates new emoji' do
        expect { subject.load(context, data) }.to change(::AwardEmoji, :count).by(1)

        epic = group.epics.last
        emoji = epic.award_emoji.first

        expect(emoji.name).to eq(data['name'])
        expect(emoji.user).to eq(user)
      end
    end

    context 'when same emoji exists' do
      it 'does not create a new emoji' do
        epic.award_emoji.create!(data)

        expect { subject.load(context, data) }.not_to change(::AwardEmoji, :count)
      end
    end

    context 'when user is not allowed to award emoji' do
      it 'raises NotAllowedError exception' do
        allow(Ability).to receive(:allowed?).with(user, :award_emoji, epic).and_return(false)

        expect { subject.load(context, data) }.to raise_error(described_class::NotAllowedError)
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
            query: BulkImports::Groups::Graphql::GetEpicAwardEmojiQuery
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
  end

  def extracted_data(has_next_page: false)
    data = [{ 'name' => 'thumbsup' }]

    page_info = {
      'has_next_page' => has_next_page,
      'next_page' => has_next_page ? 'cursor' : nil
    }

    BulkImports::Pipeline::ExtractedData.new(data: data, page_info: page_info)
  end
end
