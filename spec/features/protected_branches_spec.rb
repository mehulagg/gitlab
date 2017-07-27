require 'spec_helper'

feature 'Protected Branches', :js do
  include ProtectedBranchHelpers

  let(:user) { create(:user, :admin) }
  let(:project) { create(:project, :repository) }

  before do
    sign_in(user)
  end

  def set_protected_branch_name(branch_name)
    find(".js-protected-branch-select").trigger('click')
    find(".dropdown-input-field").set(branch_name)
    click_on("Create wildcard #{branch_name}")
  end

  describe "explicit protected branches" do
    it "allows creating explicit protected branches" do
      visit project_protected_branches_path(project)
      set_protected_branch_name('some-branch')
      set_allowed_to('merge')
      set_allowed_to('push')
      click_on "Protect"

      within(".protected-branches-list") { expect(page).to have_content('some-branch') }
      expect(ProtectedBranch.count).to eq(1)
      expect(ProtectedBranch.last.name).to eq('some-branch')
    end

    it "displays the last commit on the matching branch if it exists" do
      commit = create(:commit, project: project)
      project.repository.add_branch(user, 'some-branch', commit.id)

      visit project_protected_branches_path(project)
      set_protected_branch_name('some-branch')
      set_allowed_to('merge')
      set_allowed_to('push')
      click_on "Protect"

      within(".protected-branches-list") { expect(page).to have_content(commit.id[0..7]) }
    end

    it "displays an error message if the named branch does not exist" do
      visit project_protected_branches_path(project)
      set_protected_branch_name('some-branch')
      set_allowed_to('merge')
      set_allowed_to('push')
      click_on "Protect"

      within(".protected-branches-list") { expect(page).to have_content('branch was removed') }
    end
  end

  describe "wildcard protected branches" do
    it "allows creating protected branches with a wildcard" do
      visit project_protected_branches_path(project)
      set_protected_branch_name('*-stable')
      set_allowed_to('merge')
      set_allowed_to('push')
      click_on "Protect"

      within(".protected-branches-list") { expect(page).to have_content('*-stable') }
      expect(ProtectedBranch.count).to eq(1)
      expect(ProtectedBranch.last.name).to eq('*-stable')
    end

    it "displays the number of matching branches" do
      project.repository.add_branch(user, 'production-stable', 'master')
      project.repository.add_branch(user, 'staging-stable', 'master')

      visit project_protected_branches_path(project)
      set_protected_branch_name('*-stable')
      set_allowed_to('merge')
      set_allowed_to('push')
      click_on "Protect"

      within(".protected-branches-list") { expect(page).to have_content("2 matching branches") }
    end

    it "displays all the branches matching the wildcard" do
      project.repository.add_branch(user, 'production-stable', 'master')
      project.repository.add_branch(user, 'staging-stable', 'master')
      project.repository.add_branch(user, 'development', 'master')

      visit project_protected_branches_path(project)
      set_protected_branch_name('*-stable')
      set_allowed_to('merge')
      set_allowed_to('push')
      click_on "Protect"

      visit project_protected_branches_path(project)
      click_on "2 matching branches"

      within(".protected-branches-list") do
        expect(page).to have_content("production-stable")
        expect(page).to have_content("staging-stable")
        expect(page).not_to have_content("development")
      end
    end
  end

  describe "access control" do
    describe 'with ref permissions for users enabled' do
      before do
        stub_licensed_features(protected_refs_for_users: true)
      end

      include_examples "protected branches > access control > EE"
    end

    describe 'with ref permissions for users disabled' do
      before do
        stub_licensed_features(protected_refs_for_users: false)
      end

      include_examples "protected branches > access control > CE"

      context 'with existing access levels' do
        let(:protected_branch) { create(:protected_branch, project: project) }

        it 'shows users that can push to the branch' do
          protected_branch.push_access_levels.new(user: create(:user, name: 'Jane'))
            .save!(validate: false)

          visit project_settings_repository_path(project)

          expect(page).to have_content("The following user can also push to this branch: "\
                                       "Jane")
        end

        it 'shows groups that can push to the branch' do
          protected_branch.push_access_levels.new(group: create(:group, name: 'Team Awesome'))
            .save!(validate: false)

          visit project_settings_repository_path(project)

          expect(page).to have_content("Members of this group can also push to "\
                                       "this branch: Team Awesome")
        end

        it 'shows users that can merge into the branch' do
          protected_branch.merge_access_levels.new(user: create(:user, name: 'Jane'))
            .save!(validate: false)

          visit project_settings_repository_path(project)

          expect(page).to have_content("The following user can also merge into "\
                                       "this branch: Jane")
        end

        it 'shows groups that have can push to the branch' do
          protected_branch.merge_access_levels.new(group: create(:group, name: 'Team Awesome'))
            .save!(validate: false)
          protected_branch.merge_access_levels.new(group: create(:group, name: 'Team B'))
            .save!(validate: false)

          visit project_settings_repository_path(project)

          expect(page).to have_content("Members of these groups can also merge into "\
                                       "this branch:")
          expect(page).to have_content(/(Team Awesome|Team B) and (Team Awesome|Team B)/)
        end
      end
    end
  end
end
