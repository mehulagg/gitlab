# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Epics > User uses quick actions', :js do
  include Spec::Support::Helpers::Features::NotesHelpers

  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:epic_1) { create(:epic, group: group) }
  let(:epic_2) { create(:epic, group: group) }

  before do
    group.add_reporter(user)
    sign_in(user)
  end

  context 'on a note' do
    it 'applies quick action' do
      visit group_epic_path(group, epic_2)

      add_note("new note \n\n/parent_epic #{epic_1.to_reference}")

      expect(epic_2.parent).to eq(epic_1)
    end
  end

  context 'on create' do
  end

  # include Spec::Support::Helpers::Features::NotesHelpers

  # context "issuable common quick actions" do
  #   let(:new_url_opts) { {} }
  #   let(:maintainer) { create(:user) }
  #   let(:project) { create(:project, :public) }
  #   let!(:label_bug) { create(:label, project: project, title: 'bug') }
  #   let!(:label_feature) { create(:label, project: project, title: 'feature') }
  #   let!(:milestone) { create(:milestone, project: project, title: 'ASAP') }
  #   let(:issuable) { create(:issue, project: project) }
  #   let(:source_issuable) { create(:issue, project: project, milestone: milestone, labels: [label_bug, label_feature])}

  #   it_behaves_like 'close quick action', :issue
  #   it_behaves_like 'issuable time tracker', :issue
  # end

  # describe 'issue-only commands' do
  #   let(:user) { create(:user) }
  #   let(:project) { create(:project, :public, :repository) }
  #   let(:issue) { create(:issue, project: project, due_date: Date.new(2016, 8, 28)) }

  #   before do
  #     project.add_maintainer(user)
  #     sign_in(user)
  #     visit project_issue_path(project, issue)
  #     wait_for_all_requests
  #   end

  #   after do
  #     wait_for_requests
  #   end

  #   it_behaves_like 'create_merge_request quick action'
  #   it_behaves_like 'move quick action'
  #   it_behaves_like 'zoom quick actions'
  #   it_behaves_like 'clone quick action'
  # end
end
