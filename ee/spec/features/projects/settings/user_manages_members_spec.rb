# frozen_string_literal: true

require "spec_helper"

RSpec.describe "User manages members" do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:user) { create(:user) }

  before do
    stub_feature_flags(invite_members_group_modal: false)
    sign_in(user)
  end

  shared_examples "when group membership is unlocked" do
    before do
      group.update!(membership_lock: false)

      visit(project_project_members_path(project))
    end

    it { expect(page).to have_link("Import members").and have_selector(".project-access-select") }
  end

  shared_examples "when group membership is locked" do
    before do
      group.update!(membership_lock: true)

      visit(project_project_members_path(project))
    end

    it { expect(page).to have_no_selector(".invite-users-form") }
  end

  context "as project maintainer" do
    before do
      project.add_maintainer(user)
    end

    it_behaves_like "when group membership is unlocked"
    it_behaves_like "when group membership is locked"
  end

  context "as group owner" do
    before do
      group.add_owner(user)
    end

    it_behaves_like "when group membership is unlocked"
    it_behaves_like "when group membership is locked"
  end
end
