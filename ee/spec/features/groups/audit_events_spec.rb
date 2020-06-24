# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Groups > Audit Events', :js do
  let(:user) { create(:user) }
  let(:alex) { create(:user, name: 'Alex') }
  let(:group) { create(:group) }

  before do
    group.add_owner(user)
    group.add_developer(alex)
    sign_in(user)
  end

  context 'unlicensed' do
    before do
      stub_licensed_features(audit_events: false)
    end

    it 'returns 404' do
      reqs = inspect_requests do
        visit group_audit_events_path(group)
      end

      expect(reqs.first.status_code).to eq(404)
    end

    it 'does not have Audit Events button in head nav bar' do
      visit edit_group_path(group)

      expect(page).not_to have_link('Audit Events')
    end
  end

  it 'has Audit Events button in head nav bar' do
    visit edit_group_path(group)

    expect(page).to have_link('Audit Events')
  end

  describe 'changing a user access level' do
    it "appears in the group's audit events" do
      visit group_group_members_path(group)

      wait_for_requests

      group_member = group.members.find_by(user_id: alex)

      page.within "#group_member_#{group_member.id}" do
        click_button 'Developer'
        click_link 'Maintainer'
      end

      find(:link, text: 'Settings').click

      click_link 'Audit Events'

      page.within('.audit-log-table') do
        expect(page).to have_content 'Changed access level from Developer to Maintainer'
        expect(page).to have_content(user.name)
        expect(page).to have_content('Alex')
      end
    end
  end

  describe 'filter by date' do
    let!(:audit_event_1) { create(:group_audit_event, entity_type: 'Group', entity_id: group.id, created_at: 5.days.ago) }
    let!(:audit_event_2) { create(:group_audit_event, entity_type: 'Group', entity_id: group.id, created_at: 3.days.ago) }
    let!(:audit_event_3) { create(:group_audit_event, entity_type: 'Group', entity_id: group.id, created_at: 1.day.ago) }

    it 'shows only 2 days old events' do
      visit group_audit_events_path(group, created_after: 4.days.ago.to_date, created_before: 2.days.ago.to_date)

      find('.audit-log-table td', match: :first)

      expect(page).not_to have_content(audit_event_1.present.date)
      expect(page).to have_content(audit_event_2.present.date)
      expect(page).not_to have_content(audit_event_3.present.date)
    end

    it 'shows only yesterday events' do
      visit group_audit_events_path(group, created_after: 2.days.ago.to_date)

      find('.audit-log-table td', match: :first)

      expect(page).not_to have_content(audit_event_1.present.date)
      expect(page).not_to have_content(audit_event_2.present.date)
      expect(page).to have_content(audit_event_3.present.date)
    end

    it 'shows a message if provided date is invalid' do
      visit group_audit_events_path(group, created_after: '12-345-6789')

      expect(page).to have_content('Invalid date format. Please use UTC format as YYYY-MM-DD')
    end
  end
end
