# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin interacts with merge requests approvals settings' do
  include StubENV

  let_it_be(:application_settings) { create(:application_setting) }
  let_it_be(:user) { create(:admin) }
  let_it_be(:project) { create(:project, creator: user) }

  before do
    sign_in(user)
    gitlab_enable_admin_mode_sign_in(user)

    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    allow(License).to receive(:feature_available?).and_return(true)

    visit(admin_push_rule_path)
  end

  it 'updates instance-level merge request approval settings and enforces project-level ones' do
    page.within('.merge-request-approval-settings') do
      check 'Prevent approval of merge requests by merge request author'
      check 'Prevent approval of merge requests by merge request committers'
      check 'Prevent users from modifying merge request approvers list'
      click_button('Save changes')
    end

    visit(admin_push_rule_path)

    expect(find_field('Prevent approval of merge requests by merge request author')).to be_checked
    expect(find_field('Prevent approval of merge requests by merge request committers')).to be_checked
    expect(find_field('Prevent users from modifying merge request approvers list')).to be_checked

    visit edit_project_path(project)

    page.within('#js-merge-request-approval-settings') do
      expect(find('#project_merge_requests_author_approval')).to be_disabled.and be_checked
      expect(find('#project_merge_requests_disable_committers_approval')).to be_disabled.and be_checked
      expect(find('#project_disable_overriding_approvers_per_merge_request')).to be_disabled
      expect(find('#project_disable_overriding_approvers_per_merge_request')).not_to be_checked
    end
  end
end
