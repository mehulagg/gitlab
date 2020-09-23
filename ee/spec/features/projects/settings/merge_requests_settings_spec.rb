# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Project settings > [EE] Merge Requests', :js do
  include GitlabRoutingHelper
  include FeatureApprovalHelper

  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:group) { create(:group) }
  let(:group_member) { create(:user) }
  let(:non_member) { create(:user) }
  let!(:config_selector) { '.js-approval-rules' }
  let!(:modal_selector) { '#project-settings-approvals-create-modal' }

  before do
    sign_in(user)
    project.add_maintainer(user)
    group.add_developer(user)
    group.add_developer(group_member)
  end

  it 'adds approver' do
    visit edit_project_path(project)

    open_modal(text: 'Add approval rule')
    open_approver_select

    expect(find('.select2-results')).to have_content(user.name)
    expect(find('.select2-results')).not_to have_content(non_member.name)

    find('.user-result', text: user.name).click
    close_approver_select

    expect(find('.content-list')).to have_content(user.name)

    open_approver_select

    expect(find('.select2-results')).not_to have_content(user.name)

    close_approver_select
    within('.modal-content') do
      click_button 'Add approval rule'
    end
    wait_for_requests

    expect_avatar(find('.js-members'), user)
  end

  it 'adds approver group' do
    visit edit_project_path(project)

    open_modal(text: 'Add approval rule')
    open_approver_select

    expect(find('.select2-results')).to have_content(group.name)

    find('.user-result', text: group.name).click
    close_approver_select

    expect(find('.content-list')).to have_content(group.name)

    within('.modal-content') do
      click_button 'Add approval rule'
    end
    wait_for_requests

    expect_avatar(find('.js-members'), group.users)
  end

  context 'with an approver group' do
    let(:non_group_approver) { create(:user) }
    let!(:rule) { create(:approval_project_rule, project: project, groups: [group], users: [non_group_approver]) }

    before do
      project.add_developer(non_group_approver)
    end

    it 'removes approver group' do
      visit edit_project_path(project)

      expect_avatar(find('.js-members'), rule.approvers)

      open_modal
      remove_approver(group.name)
      click_button "Update approval rule"
      wait_for_requests

      expect_avatar(find('.js-members'), [non_group_approver])
    end
  end

  context 'issuable default templates feature not available' do
    before do
      stub_licensed_features(issuable_default_templates: false)
    end

    it 'input to configure merge request template is not shown' do
      visit edit_project_path(project)

      expect(page).not_to have_selector('#project_merge_requests_template')
    end

    it "does not mention the merge request template in the section's description text" do
      visit edit_project_path(project)

      expect(page).to have_content('Choose your merge method, merge options, merge checks, and merge suggestions.')
    end
  end

  context 'issuable default templates feature is available' do
    before do
      stub_licensed_features(issuable_default_templates: true)
    end

    it 'input to configure merge request template is shown' do
      visit edit_project_path(project)

      expect(page).to have_selector('#project_merge_requests_template')
    end

    it "mentions the merge request template in the section's description text" do
      visit edit_project_path(project)

      expect(page).to have_content('Choose your merge method, merge options, merge checks, merge suggestions, and set up a default description template for merge requests.')
    end
  end
end
