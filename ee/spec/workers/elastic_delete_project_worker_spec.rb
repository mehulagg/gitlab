# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ElasticDeleteProjectWorker, :elastic do
  subject { described_class.new }

  # Create admin user and search globally to avoid dealing with permissions in
  # these tests
  let(:user) { create(:admin) }
  let(:search_options) { { options: { current_user: user, project_ids: :any } } }

  before do
    stub_ee_application_setting(elasticsearch_indexing: true)
  end

  it 'deletes a project with all nested objects', :aggregate_failures do
    project = create :project, :repository
    issue = create :issue, project: project
    milestone = create :milestone, project: project
    note = create :note, project: project
    merge_request = create :merge_request, target_project: project, source_project: project

    ensure_elasticsearch_index!

    ## All database objects + data from repository. The absolute value does not matter
    expect(Project.elastic_search('*', **search_options).records).to include(project)
    expect(Issue.elastic_search('*', **search_options).records).to include(issue)
    expect(Milestone.elastic_search('*', **search_options).records).to include(milestone)
    expect(Note.elastic_search('*', **search_options).records).to include(note)
    expect(MergeRequest.elastic_search('*', **search_options).records).to include(merge_request)

    subject.perform(project.id, project.es_id)
    ensure_elasticsearch_index!

    expect(Project.elastic_search('*', **search_options).total_count).to be(0)
    expect(Issue.elastic_search('*', **search_options).total_count).to be(0)
    expect(Milestone.elastic_search('*', **search_options).total_count).to be(0)
    expect(Note.elastic_search('*', **search_options).total_count).to be(0)
    expect(MergeRequest.elastic_search('*', **search_options).total_count).to be(0)

    # verify that entire index is empty
    # searches use joins on the parent record (project)
    # and the previous queries will not find data left in the index
    helper = Gitlab::Elastic::Helper.default

    expect(helper.documents_count).to be(0)
  end
end
