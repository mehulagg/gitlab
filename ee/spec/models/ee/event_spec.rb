# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Event do
  describe '#visible_to_user?' do
    let_it_be(:non_member) { create(:user) }
    let_it_be(:member) { create(:user) }
    let_it_be(:guest) { create(:user) }
    let_it_be(:reporter) { create(:user) }
    let_it_be(:author) { create(:author) }
    let_it_be(:admin) { create(:admin) }
    let_it_be(:project) { create(:project) }

    let(:users) { [non_member, member, reporter, guest, author, admin] }

    let(:epic) { create(:epic, group: group, author: author) }
    let(:note_on_epic) { create(:note, :on_epic, noteable: epic) }
    let(:event) { described_class.new(group: group, target: target, author: author) }

    before do
      stub_licensed_features(epics: true)

      project.add_developer(member)
      project.add_guest(guest)
      project.add_reporter(reporter)

      if defined?(group)
        group.add_developer(member)
        group.add_guest(guest)
      end
    end

    RSpec::Matchers.define :be_visible_to do |user|
      match do |event|
        event.visible_to_user?(user)
      end

      failure_message do |event|
        "expected that #{event} should be visible to #{user}"
      end

      failure_message_when_negated do |event|
        "expected that #{event} would not be visible to #{user}"
      end
    end

    RSpec::Matchers.define :have_access_to do |event|
      match do |user|
        event.visible_to_user?(user)
      end

      failure_message do |user|
        "expected that #{event} should be visible to #{user}"
      end

      failure_message_when_negated do |user|
        "expected that #{event} would not be visible to #{user}"
      end
    end

    shared_examples 'visible to group members only' do
      it 'is not visible to other users', :aggregate_failures do
        expect(event).not_to be_visible_to(non_member)
        expect(event).not_to be_visible_to(author)

        expect(event).to be_visible_to(member)
        expect(event).to be_visible_to(guest)
      end

      context 'when admin mode enabled', :enable_admin_mode do
        it 'is visible to admin', :aggregate_failures do
          expect(event).to be_visible_to(admin)
        end
      end

      context 'when admin mode disabled' do
        # Skipped because `Group#max_member_access_for_user` needs to be migrated to use admin mode
        # See https://gitlab.com/gitlab-org/gitlab/-/issues/207950
        xit 'is not visible to admin', :aggregate_failures do
          expect(event).not_to be_visible_to(admin)
        end
      end
    end

    shared_examples 'visible to everybody' do
      it 'is visible to other users', :aggregate_failures do
        expect(users).to all(have_access_to(event))
      end
    end

    context 'epic event' do
      let(:target) { epic }

      context 'on public group' do
        let(:group) { create(:group, :public) }

        it_behaves_like 'visible to everybody'
      end

      context 'on private group' do
        let(:group) { create(:group, :private) }

        it_behaves_like 'visible to group members only'
      end
    end

    context 'epic note event' do
      let(:target) { note_on_epic }

      context 'on public group' do
        let(:group) { create(:group, :public) }

        it_behaves_like 'visible to everybody'
      end

      context 'private group' do
        let(:group) { create(:group, :private) }

        it_behaves_like 'visible to group members only'
      end
    end
  end

  describe '#action_name' do
    let_it_be(:approved_event) {create(:event, :approved)}
    let_it_be(:created_event) {create(:event, :created)}

    it 'returns the appropriate action name' do
      expect(approved_event.action_name).to eq 'approved'
      expect(created_event.action_name).to eq 'created'
    end
  end

  describe '#approved_action?' do
    let_it_be(:approved_event) {create(:event, :approved)}
    let_it_be(:created_event) {create(:event, :created)}

    it 'return true only for approved event type' do
      expect(approved_event.approved_action?).to be true
      expect(created_event.approved_action?).to be false
    end
  end
end
