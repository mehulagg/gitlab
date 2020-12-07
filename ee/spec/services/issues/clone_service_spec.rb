# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issues::CloneService do
  let_it_be(:user) { create(:user) }
  let_it_be(:author) { create(:user) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:sub_group_1) { create(:group, :private, parent: group) }
  let_it_be(:old_project) { create(:project, namespace: group) }
  let_it_be(:new_project) { create(:project, namespace: sub_group_1) }
  let_it_be(:old_issue) { create(:issue, project: old_project, author: author, epic: epic) }

  subject(:clone_service) do
    described_class.new(old_project, user)
  end

  let(:new_issue) { clone_service.execute(old_issue, new_project) }

  context 'user has enough permissions' do
    before do
      old_project.add_reporter(user)
      new_project.add_reporter(user)
    end

    it 'does not copy epic' do
      expect(new_issue.epic).to be_nil
    end
  end
end
