# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merge Requests > User filters', :js do
  include FilteredSearchHelpers

  let(:project) { create(:project, :public, :repository) }
  let(:user)    { project.creator }
  let(:group_user) { create(:user) }
  let(:first_user) { create(:user) }

  let!(:merge_request_with_approver) do
    create(:merge_request, approval_users: [first_user], title: 'Bugfix1', source_project: project, source_branch: 'bugfix1')
  end

  let!(:merge_request_with_two_approvers) do
    create(:merge_request, title: 'Bugfix2', approval_users: [user, first_user], source_project: project, source_branch: 'bugfix2')
  end

  let!(:merge_request) { create(:merge_request, title: 'Bugfix3', source_project: project, source_branch: 'bugfix3') }
  let!(:merge_request_with_group_approver) do
    group = create(:group)
    group.add_developer(group_user)

    create(:merge_request, approval_groups: [group], title: 'Bugfix4', source_project: project, source_branch: 'bugfix4')
  end

  before do
    sign_in(user)
    visit project_merge_requests_path(project)
  end

  context 'by "approvers"' do
    context 'filtering by approver:none' do
      it 'applies the filter' do
        input_filtered_search('approver:=none')

        expect(page).to have_issuable_counts(open: 1, closed: 0, all: 1)

        expect(page).not_to have_content 'Bugfix1'
        expect(page).not_to have_content 'Bugfix2'
        expect(page).not_to have_content 'Bugfix4'
        expect(page).to have_content 'Bugfix3'
      end
    end

    context 'filtering by approver:any' do
      it 'applies the filter' do
        input_filtered_search('approver:=any')

        expect(page).to have_issuable_counts(open: 3, closed: 0, all: 3)

        expect(page).to have_content 'Bugfix1'
        expect(page).to have_content 'Bugfix2'
        expect(page).to have_content 'Bugfix4'
        expect(page).not_to have_content 'Bugfix3'
      end
    end

    context 'filtering by approver:@username' do
      it 'applies the filter' do
        input_filtered_search("approver:=@#{first_user.username}")

        expect(page).to have_issuable_counts(open: 2, closed: 0, all: 2)

        expect(page).to have_content 'Bugfix1'
        expect(page).to have_content 'Bugfix2'
        expect(page).not_to have_content 'Bugfix3'
        expect(page).not_to have_content 'Bugfix4'
      end
    end

    context 'filtering by multiple approvers' do
      it 'applies the filter' do
        input_filtered_search("approver:=@#{first_user.username} approver:=@#{user.username}")

        expect(page).to have_issuable_counts(open: 1, closed: 0, all: 1)

        expect(page).to have_content 'Bugfix2'
        expect(page).not_to have_content 'Bugfix1'
        expect(page).not_to have_content 'Bugfix3'
        expect(page).not_to have_content 'Bugfix4'
      end
    end

    context 'filtering by an approver from a group' do
      it 'applies the filter' do
        input_filtered_search("approver:=@#{group_user.username}")

        expect(page).to have_issuable_counts(open: 1, closed: 0, all: 1)

        expect(page).to have_content 'Bugfix4'
        expect(page).not_to have_content 'Bugfix1'
        expect(page).not_to have_content 'Bugfix2'
        expect(page).not_to have_content 'Bugfix3'
      end
    end
  end

  context 'by "approved by"' do
    let!(:merge_request_with_first_user_approval) do
      create(:merge_request, source_project: project, title: 'Bugfix5').tap do |mr|
        create(:approval, merge_request: mr, user: first_user)
      end
    end

    let!(:merge_request_with_group_user_approved) do
      group = create(:group)
      group.add_developer(group_user)

      create(:merge_request, source_project: project, title: 'Bugfix6', approval_groups: [group], source_branch: 'bugfix6').tap do |mr|
        create(:approval, merge_request: mr, user: group_user)
      end
    end

    context 'filtering by approved-by:none' do
      it 'applies the filter' do
        input_filtered_search('approved-by:=none')

        expect(page).to have_issuable_counts(open: 4, closed: 0, all: 4)

        expect(page).not_to have_content 'Bugfix5'
        expect(page).to have_content 'Bugfix3'
      end
    end

    context 'filtering by approved-by:any' do
      it 'applies the filter' do
        input_filtered_search('approved-by:=any')

        expect(page).to have_issuable_counts(open: 2, closed: 0, all: 2)

        expect(page).to have_content 'Bugfix5'
        expect(page).not_to have_content 'Bugfix3'
      end
    end

    context 'filtering by approved-by:@username' do
      it 'applies the filter' do
        input_filtered_search("approved-by:=@#{first_user.username}")

        expect(page).to have_issuable_counts(open: 1, closed: 0, all: 1)

        expect(page).to have_content 'Bugfix5'
        expect(page).not_to have_content 'Bugfix3'
      end
    end

    context 'filtering by an approver from a group' do
      it 'applies the filter' do
        input_filtered_search("approved-by:=@#{group_user.username}")

        expect(page).to have_issuable_counts(open: 1, closed: 0, all: 1)

        expect(page).to have_content 'Bugfix6'
        expect(page).not_to have_content 'Bugfix5'
        expect(page).not_to have_content 'Bugfix3'
      end
    end
  end
end
