# frozen_string_literal: true

require 'spec_helper'

describe 'Epic /move quick action', :js do
  set(:user) { create(:user) }
  let(:source_group) { create(:group, :public) }
  let(:target_group) { create(:group, :public) }
  let(:epic) { create(:epic, group: source_group) }
  let(:target_path) { target_group.path }

  before do
    stub_licensed_features(epics: true)
    stub_feature_flags(move_epic_quick_action: true)

    sign_in(user)
  end

  subject do
    visit group_epic_path(source_group, epic)

    fill_in('Write a comment or drag your files here…', with: "/move #{target_path}")
    click_button 'Comment'
    wait_for_requests
  end

  context 'with feature flag disabled' do
    before do
      stub_feature_flags(move_epic_quick_action: false)
    end

    it 'does not create a new epic' do
      subject

      expect(target_group.epics).to be_empty
    end

    it 'does not navigate away' do
      subject

      expect(page).to have_current_path(group_epic_path(source_group, epic))
    end

    # submitted quick actions where the condition is false currently show no error
    # see https://gitlab.com/gitlab-org/gitlab-ce/issues/62229
    it 'does not show an error' do
      subject

      expect(page).to have_no_selector('.flash-text')
    end
  end

  context 'for missing permission in target group' do
    before do
      source_group.add_owner(user)
      target_group.add_guest(user)
    end

    it 'displays an error message' do
      subject

      expect(find('.flash-text')).to have_text("Moving this epic failed because of missing permission in group #{target_path}")
    end
  end

  context 'for non-existent target group' do
    let(:target_path) { 'this-group-does-not-exist' }

    before do
      source_group.add_owner(user)
    end

    it 'displays an error message' do
      subject

      expect(find('.flash-text')).to have_text("Moving this epic failed because the group #{target_path} doesn't exist")
    end
  end

  context 'for sufficient permission' do
    before do
      source_group.add_owner(user)
      target_group.add_owner(user)
    end

    it 'closes the original epic' do
      subject

      expect(epic).to be_closed
    end

    it 'creates a new epic and navigates to it' do
      subject

      expect(target_group.epics.count).to eq(1)
      new_epic = target_group.epics.first
      expect(new_epic.title).to eq(epic.title)
      expect(new_epic.description).to eq(epic.description)
      expect(new_epic.author).to eq(epic.author)
      expect(page).to have_current_path(group_epic_path(target_group, new_epic))
    end
  end
end
