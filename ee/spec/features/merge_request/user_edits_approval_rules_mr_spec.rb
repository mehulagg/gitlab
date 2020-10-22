# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merge request > User edits MR with approval rules', :js do
  include Select2Helper

  include_context 'project with approval rules'

  let(:merge_request) { create(:merge_request, source_project: project) }
  let(:mr_rule_names) { %w[foo lorem ipsum] }
  let(:modal_id) { '#mr-edit-approvals-create-modal' }
  let(:members_selector) { "#{modal_id} input[name=members]" }
  let(:members_search_selector) { "#{modal_id} .select2-input" }

  def page_rule_names
    page.all('.js-approval-rules table .js-name')
  end

  def add_approval_rule_member(type, name)
    open_select2 members_selector
    wait_for_requests
    find(".select2-result-label .#{type}-result", text: name).click
    close_select2 members_selector
  end

  before do
    project.update_attribute(:disable_overriding_approvers_per_merge_request, false)
    stub_licensed_features(multiple_approval_rules: true)

    approver = create(:user)
    mr_rule_names.each do |name|
      create(:approval_merge_request_rule,
        merge_request: merge_request, approvals_required: 1, name: name, users: [approver])
    end

    sign_in(author)
    visit(edit_project_merge_request_path(project, merge_request))

    wait_for_requests
  end

  it "shows approval rules" do
    names = page_rule_names.map(&:text)

    expect(names).to eq(mr_rule_names)
  end

  it "allows user to create approval rule" do
    rule_name = "Custom Approval Rule"

    click_button "Add approval rule"

    fill_in "Rule name", with: rule_name

    add_approval_rule_member('user', approver.name)

    find("#{modal_id} button", text: 'Add approval rule').click
    wait_for_requests

    expect(page_rule_names.last).to have_text(rule_name)
  end

  context "with public group" do
    let!(:group) { create(:group, :public) }

    before do
      group.add_developer create(:user)

      click_button "Add approval rule"
    end

    it "with empty search, does not show public group" do
      open_select2 members_selector
      wait_for_requests

      expect(page).not_to have_selector('.select2-result-label .group-result', text: group.name)
    end

    it "with non-empty search, shows public group" do
      find(members_search_selector).set group.name
      wait_for_requests

      expect(page).to have_selector('.select2-result-label .group-result', text: group.name)
    end
  end
end
