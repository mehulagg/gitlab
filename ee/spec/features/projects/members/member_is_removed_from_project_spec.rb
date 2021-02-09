# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects > Members > Member is removed from project' do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:other_user) { create(:user) }

  before do
    project.add_maintainer(user)
    project.add_maintainer(other_user)
  end

  context 'when `vue_project_members_list` feature flag is enabled', :js do
    before do
      sign_in(user)
      visit project_project_members_path(project)
    end

    it 'user is removed from project' do
      click_button 'Leave'

      page.within('[role="dialog"]') do
        click_button('Leave')
      end

      expect(project.users.exists?(user.id)).to be_falsey
    end

    context 'when the user has been specifically allowed to access a protected branch' do
      let!(:matching_protected_branch) { create(:protected_branch, authorize_user_to_push: user, authorize_user_to_merge: user, project: project) }
      let!(:non_matching_protected_branch) { create(:protected_branch, authorize_user_to_push: other_user, authorize_user_to_merge: other_user, project: project) }

      it 'user leaves project' do
        click_button 'Leave'

        page.within('[role="dialog"]') do
          click_button('Leave')
        end

        expect(project.users.exists?(user.id)).to be_falsey
        expect(matching_protected_branch.push_access_levels.where(user: user)).not_to exist
        expect(matching_protected_branch.merge_access_levels.where(user: user)).not_to exist
        expect(non_matching_protected_branch.push_access_levels.where(user: other_user)).to exist
        expect(non_matching_protected_branch.merge_access_levels.where(user: other_user)).to exist
      end
    end
  end

  context 'when `vue_project_members_list` feature flag is disabled' do
    before do
      stub_feature_flags(vue_project_members_list: false)

      sign_in(user)
      visit project_project_members_path(project)
    end

    it 'user is removed from project' do
      click_link 'Leave'

      expect(project.users.exists?(user.id)).to be_falsey
    end

    context 'when the user has been specifically allowed to access a protected branch' do
      let!(:matching_protected_branch) { create(:protected_branch, authorize_user_to_push: user, authorize_user_to_merge: user, project: project) }
      let!(:non_matching_protected_branch) { create(:protected_branch, authorize_user_to_push: other_user, authorize_user_to_merge: other_user, project: project) }

      it 'user leaves project' do
        click_link 'Leave'

        expect(project.users.exists?(user.id)).to be_falsey
        expect(matching_protected_branch.push_access_levels.where(user: user)).not_to exist
        expect(matching_protected_branch.merge_access_levels.where(user: user)).not_to exist
        expect(non_matching_protected_branch.push_access_levels.where(user: other_user)).to exist
        expect(non_matching_protected_branch.merge_access_levels.where(user: other_user)).to exist
      end
    end
  end
end
