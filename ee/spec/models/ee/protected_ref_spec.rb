# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::ProtectedRef do
  context 'for protected branches' do
    it 'deletes all related access levels' do
      protected_branch = create(:protected_branch)

      2.times do
        group = create(:group)
        protected_branch.project.project_group_links.create!(group: group)
        protected_branch.merge_access_levels.create!(group: group)
      end

      2.times do
        user = create(:user)
        protected_branch.project.add_developer(user)
        protected_branch.push_access_levels.create!(user: user)
      end

      protected_branch.destroy!

      expect(ProtectedBranch::MergeAccessLevel.count).to be(0)
      expect(ProtectedBranch::PushAccessLevel.count).to be(0)
    end
  end
end
