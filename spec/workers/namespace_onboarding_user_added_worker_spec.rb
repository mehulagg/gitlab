# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceOnboardingUserAddedWorker, '#perform' do
  let_it_be(:group) { create(:group) }

  before do
    group.add_owner(create(:user))
  end

  context 'only the owner is member of the group' do
    it 'records the event' do
      expect(NamespaceOnboardingAction).to receive(:create_action)
        .with(group, :user_added).and_call_original

      expect do
        subject.perform(group.id)
      end.to change(NamespaceOnboardingAction, :count).by(1)
    end
  end

  context 'another user besides the owner is member of the group' do
    before do
      group.add_user(create(:user), Gitlab::Access::GUEST)
    end

    it 'does not record the event' do
      expect(NamespaceOnboardingAction).not_to receive(:create_action)

      expect do
        subject.perform(group.id)
      end.not_to change(NamespaceOnboardingAction, :count)
    end
  end
end
