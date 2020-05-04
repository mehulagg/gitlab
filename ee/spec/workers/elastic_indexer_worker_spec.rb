# frozen_string_literal: true

require 'spec_helper'

describe ElasticIndexerWorker, :elastic do
  subject { described_class.new }

  # Create admin user and search globally to avoid dealing with permissions in
  # these tests
  let(:user) { create(:admin) }
  let(:search_options) { { options: { current_user: user, project_ids: :any } } }

  before do
    stub_ee_application_setting(elasticsearch_indexing: true)

    Elasticsearch::Model.client =
      Gitlab::Elastic::Client.build(Gitlab::CurrentSettings.elasticsearch_config)
  end

  it 'returns true if ES disabled' do
    stub_ee_application_setting(elasticsearch_indexing: false)

    expect_any_instance_of(Elasticsearch::Model).not_to receive(:__elasticsearch__)

    expect(subject.perform("index", "Milestone", 1, 1)).to be_truthy
  end

  describe 'Indexing, updating, and deleting records' do
    using RSpec::Parameterized::TableSyntax

    where(:type, :name) do
      :project       | "Project"
      :issue         | "Issue"
      :note          | "Note"
      :milestone     | "Milestone"
      :merge_request | "MergeRequest"
    end

    with_them do
      context 'index' do
        let(:object) { create(type) }
        let(:job_args) { ["index", name, object.id, object.es_id] }

        include_examples 'an idempotent worker' do
          it 'calls record indexing' do
            expect_next_instance_of(Elastic::IndexRecordService) do |service|
              expect(service).to receive(:execute).with(object, true, {}).and_return(true)
            end.exactly(IdempotentWorkerHelper::WORKER_EXEC_TIMES).times

            subject
          end
        end
      end

      context 'delete' do
        let(:object) do
          object = nil

          Sidekiq::Testing.disable! do
            object = create(type)

            if type != :project
              # You cannot find anything in the index if it's parent project is
              # not first indexed.
              described_class.new.perform("index", "Project", object.project.id, object.project.es_id)
            end

            described_class.new.perform("index", name, object.id, object.es_id)
            ensure_elasticsearch_index!
            object.destroy
          end

          object
        end
        let(:job_args) { ["delete", name, object.id, object.es_id, { 'es_parent' => object.es_parent }] }

        def total_count(object)
          object.class.elastic_search('*', search_options).total_count
        end

        before { expect(total_count(object)).to eq(1) }

        include_examples 'an idempotent worker' do
          it 'deletes from index when an object is deleted' do
            subject
            ensure_elasticsearch_index!

            expect(total_count(object)).to eq(0)
          end
        end
      end
    end
  end

  context 'nested objects' do
    let(:project) { create :project, :repository }
    let(:issue) { create :issue, project: project }
    let(:milestone) { create :milestone, project: project }
    let(:note) { create :note, project: project }
    let(:merge_request) { create :merge_request, target_project: project, source_project: project }

    let(:job_args) { ["delete", "Project", project.id, project.es_id] }

    before do
      Sidekiq::Testing.disable! do
        described_class.new.perform("index", "Project", project.id, project.es_id)
        described_class.new.perform("index", "Issue", issue.id, issue.es_id)
        described_class.new.perform("index", "Milestone", milestone.id, milestone.es_id)
        described_class.new.perform("index", "Note", note.id, note.es_id)
        described_class.new.perform("index", "MergeRequest", merge_request.id, merge_request.es_id)
      end

      ElasticCommitIndexerWorker.new.perform(project.id)
      ensure_elasticsearch_index!

      ## All database objects + data from repository. The absolute value does not matter
      expect(Project.elastic_search('*', search_options).records).to include(project)
      expect(Issue.elastic_search('*', search_options).records).to include(issue)
      expect(Milestone.elastic_search('*', search_options).records).to include(milestone)
      expect(Note.elastic_search('*', search_options).records).to include(note)
      expect(MergeRequest.elastic_search('*', search_options).records).to include(merge_request)
    end

    include_examples 'an idempotent worker' do
      it 'deletes a project with all nested objects' do
        subject
        ensure_elasticsearch_index!

        expect(Project.elastic_search('*', search_options).total_count).to be(0)
        expect(Issue.elastic_search('*', search_options).total_count).to be(0)
        expect(Milestone.elastic_search('*', search_options).total_count).to be(0)
        expect(Note.elastic_search('*', search_options).total_count).to be(0)
        expect(MergeRequest.elastic_search('*', search_options).total_count).to be(0)
      end
    end
  end

  it 'retries if index raises error' do
    object = create(:project)

    expect_next_instance_of(Elastic::IndexRecordService) do |service|
      allow(service).to receive(:execute).and_raise(Elastic::IndexRecordService::ImportError)
    end

    expect do
      subject.perform("index", 'Project', object.id, object.es_id)
    end.to raise_error(Elastic::IndexRecordService::ImportError)
  end

  it 'ignores Elasticsearch::Transport::Transport::Errors::NotFound error' do
    object = create(:project)

    expect_next_instance_of(Elastic::IndexRecordService) do |service|
      allow(service).to receive(:execute).and_raise(Elasticsearch::Transport::Transport::Errors::NotFound)
    end

    expect(subject.perform("index", 'Project', object.id, object.es_id)).to eq(true)
  end

  it 'ignores missing records' do
    expect(subject.perform("index", 'Project', -1, 'project_-1')).to eq(true)
  end
end
