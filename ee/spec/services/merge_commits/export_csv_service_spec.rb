# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeCommits::ExportCsvService do
  subject { described_class.new(user, group) }

  let_it_be(:group) { create(:group, name: 'Kombucha lovers') }
  let_it_be(:user) { create(:user, name: 'John Cena') }
  let_it_be(:project) { create(:project, :repository, namespace: group, name: 'Starter kit') }
  let_it_be(:merge_user) { create(:user, name: 'Brock Lesnar') }
  let_it_be(:merge_request) { create(:merge_request_with_diffs, :with_merged_metrics, merged_by: merge_user, source_project: project, target_project: project, author: user, merge_commit_sha: '347yrv45') }
  let_it_be(:approval) { create(:approval, merge_request: merge_request, user: merge_user) }
  let_it_be(:approval2) { create(:approval, merge_request: merge_request, user_id: create(:user, name: 'Kane').id) }
  let_it_be(:open_merge_request) { create(:merge_request, source_project: project, target_project: project, author: user) }

  before_all do
    project.add_maintainer(user)
  end

  it { expect(subject.csv_data).to be_success }

  it 'includes the appropriate headers' do
    expect(csv.headers).to eq(['Merge Commit', 'Author', 'Merge Request', 'Merged By', 'Pipeline', 'Group', 'Project', 'Approver(s)'])
  end

  context 'data verification' do
    specify 'Merge Commit' do
      expect(csv[0]['Merge Commit']).to eq '347yrv45'
    end

    specify 'Author' do
      expect(csv[0]['Author']).to eq 'John Cena'
    end

    specify 'Merge Request' do
      expect(csv[0]['Merge Request']).to eq merge_request.id.to_s
    end

    specify 'Merged By' do
      expect(csv[0]['Merged By']).to eq 'Brock Lesnar'
    end

    specify 'Pipeline' do
      expect(csv[0]['Pipeline']).to eq merge_request.metrics.pipeline_id.to_s
    end

    specify 'Group' do
      expect(csv[0]['Group']).to eq 'Kombucha lovers'
    end

    specify 'Project' do
      expect(csv[0]['Project']).to eq 'Starter kit'
    end

    specify 'Approver(s)' do
      expect(csv[0]['Approver(s)']).to eq 'Brock Lesnar | Kane'
    end
  end

  context 'with multiple merge requests' do
    let_it_be(:merge_request_2) { create(:merge_request_with_diffs, source_project: project, target_project: project, state: :merged, merge_commit_sha: 'rurebf') }

    it { expect(csv.count).to eq 2 }

    context 'by commit_sha filter' do
      context 'when valid' do
        subject { described_class.new(user, group, { commit_sha: merge_request_2.merge_commit_sha }) }

        it { expect(subject.csv_data).to be_success }

        it { expect(csv.count).to eq 1 }

        it do
          expect(csv[0]['Merge Commit']).to eq merge_request_2.merge_commit_sha
        end
      end

      context 'when merge commit does not exist' do
        subject { described_class.new(user, group, { commit_sha: 'inexistent' }) }

        it { expect(csv.count).to eq 0 }
      end
    end
  end

  def csv
    data = subject.csv_data.payload

    CSV.parse(data, headers: true)
  end
end
