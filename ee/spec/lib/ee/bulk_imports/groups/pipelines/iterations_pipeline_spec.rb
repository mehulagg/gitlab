# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Pipelines::IterationsPipeline do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:cursor) { 'cursor' }
  let(:timestamp) { Time.new(2020, 01, 01).utc }
  let(:bulk_import) { create(:bulk_import, user: user) }
  let(:entity) do
    create(
      :bulk_import_entity,
      bulk_import: bulk_import,
      source_full_path: 'source/full/path',
      destination_name: 'My Destination Group',
      destination_namespace: group.full_path,
      group: group
    )
  end

  let(:context) { BulkImports::Pipeline::Context.new(entity) }

  subject { described_class.new(context) }

  before do
    stub_licensed_features(iterations: true)
    group.add_owner(user)
  end

  def iteration_data(title, start_date: Date.today)
    {
      'title' => title,
      'description' => 'desc',
      'state' => 'upcoming',
      'start_date' => start_date,
      'due_date' => start_date + 1.day,
      'created_at' => timestamp.to_s,
      'updated_at' => timestamp.to_s
    }
  end

  def extractor_data(title:, has_next_page:, cursor: nil, start_date: Date.today)
    page_info = {
      'end_cursor' => cursor,
      'has_next_page' => has_next_page
    }

    BulkImports::Pipeline::ExtractedData.new(data: [iteration_data(title, start_date: start_date)], page_info: page_info)
  end

  describe '#run' do
    it 'imports group iterations' do
      first_page = extractor_data(title: 'iteration1', has_next_page: true, cursor: cursor)
      last_page = extractor_data(title: 'iteration2', has_next_page: false, start_date: Date.today + 2.days)

      allow_next_instance_of(BulkImports::Common::Extractors::GraphqlExtractor) do |extractor|
        allow(extractor)
          .to receive(:extract)
          .and_return(first_page, last_page)
      end

      expect { subject.run }.to change(Iteration, :count).by(2)

      expect(group.iterations.pluck(:title)).to contain_exactly('iteration1', 'iteration2')

      iteration = group.iterations.last

      expect(iteration.description).to eq('desc')
      expect(iteration.state).to eq('upcoming')
      expect(iteration.start_date).to eq(Date.today + 2.days)
      expect(iteration.due_date).to eq(Date.today + 3.days)
      expect(iteration.created_at).to eq(timestamp)
      expect(iteration.updated_at).to eq(timestamp)
    end
  end

  describe '#after_run' do
    context 'when extracted data has next page' do
      it 'updates tracker information and runs pipeline again' do
        data = extractor_data(title: 'iteration', has_next_page: true, cursor: cursor)

        expect(subject).to receive(:run)

        subject.after_run(data)

        tracker = entity.trackers.find_by(relation: :iterations)

        expect(tracker.has_next_page).to eq(true)
        expect(tracker.next_page).to eq(cursor)
      end
    end

    context 'when extracted data has no next page' do
      it 'updates tracker information and does not run pipeline' do
        data = extractor_data(title: 'iteration', has_next_page: false)

        expect(subject).not_to receive(:run)

        subject.after_run(data)

        tracker = entity.trackers.find_by(relation: :iterations)

        expect(tracker.has_next_page).to eq(false)
        expect(tracker.next_page).to be_nil
      end
    end
  end

  describe '#load' do
    it 'creates the iteration' do
      data = iteration_data('iteration')

      expect { subject.load(context, data) }.to change(Iteration, :count).by(1)
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
            query: EE::BulkImports::Groups::Graphql::GetIterationsQuery
          }
        )
    end

    it 'has transformers' do
      expect(described_class.transformers)
        .to contain_exactly(
          { klass: BulkImports::Common::Transformers::ProhibitedAttributesTransformer, options: nil }
        )
    end
  end
end
