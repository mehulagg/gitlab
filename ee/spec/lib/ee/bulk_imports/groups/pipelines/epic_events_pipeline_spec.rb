# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Pipelines::EpicEventsPipeline do
  let_it_be(:cursor) { 'cursor' }
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:tracker) { "epic_#{epic.iid}_events" }
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

  let_it_be(:context) { BulkImports::Pipeline::Context.new(entity) }

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
    it 'imports epic events and resource state events' do
      data = extractor_data(has_next_page: false, cursor: cursor)

      allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
        allow(extractor)
          .to receive(:extract)
          .and_return(data)
      end

      subject.run
      expect(epic.events.first.action).to eq('closed')
      expect(epic.resource_state_events.first.state).to eq('closed')
    end
  end

  describe '#transform' do
    it 'downcases action & adds group_id' do
      data = { 'action' => 'CLOSED' }
      result = subject.transform(context, data)

      expect(result['group_id']).to eq(group.id)
      expect(result['action']).to eq(data['action'].downcase)
    end

    context 'when action is not listed as permitted' do
      it 'returns' do
        data = { 'action' => 'created' }

        expect(subject.transform(nil, data)).to eq(nil)
      end
    end
  end

  describe '#load' do
    context 'when exception occurs during resource state event creation' do
      it 'reverts created event' do
        allow(subject).to receive(:create_resource_state_event!).and_raise(StandardError)

        data = { 'action' => 'reopened', 'author_id' => user.id }

        expect { subject.load(context, data) }.to raise_error(StandardError)
        expect(epic.events.count).to eq(0)
        expect(epic.resource_state_events.count).to eq(0)
      end
    end

    context 'when epic could not be found' do
      it 'does not create new event' do
        context.extra[:epic_iid] = 'not_iid'

        expect { subject.load(context, nil) }.to not_change { Event.count }.and not_change { ResourceStateEvent.count }
      end
    end
  end

  describe '#after_run' do
    context 'when extracted data has next page' do
      it 'updates tracker information and runs pipeline again' do
        data = extractor_data(has_next_page: true, cursor: cursor)

        expect(subject).to receive(:run)

        subject.after_run(data)

        page_tracker = entity.trackers.find_by(relation: tracker)

        expect(page_tracker.has_next_page).to eq(true)
        expect(page_tracker.next_page).to eq(cursor)
      end
    end

    context 'when extracted data has no next page' do
      it 'updates tracker information and does not run pipeline' do
        data = extractor_data(has_next_page: false)

        expect(subject).not_to receive(:run)

        subject.after_run(data)

        page_tracker = entity.trackers.find_by(relation: tracker)

        expect(page_tracker.has_next_page).to eq(false)
        expect(page_tracker.next_page).to be_nil
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
            query: EE::BulkImports::Groups::Graphql::GetEpicEventsQuery
          }
        )
    end

    it 'has transformers' do
      expect(described_class.transformers)
        .to contain_exactly(
          { klass: BulkImports::Common::Transformers::ProhibitedAttributesTransformer, options: nil },
          { klass: BulkImports::Common::Transformers::UserReferenceTransformer, options: { reference: 'author' } }
        )
    end
  end

  def extractor_data(has_next_page:, cursor: nil)
    data = [
      {
        'action' => 'CLOSED',
        'created_at' => '2021-02-15T15:08:57Z',
        'updated_at' => '2021-02-15T16:08:57Z',
        'author' => {
          'public_email' => user.email
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
