# frozen_string_literal: true

require 'spec_helper'

describe 'Admin::AuditLogs', :js do
  include Select2Helper

  let(:user) { create(:user) }

  before do
    sign_in(create(:admin))
  end

  context 'unlicensed' do
    before do
      stub_licensed_features(admin_audit_log: false)
    end

    it 'returns 404' do
      reqs = inspect_requests do
        visit admin_audit_logs_path
      end

      expect(reqs.first.status_code).to eq(404)
    end
  end

  context 'licensed' do
    before do
      stub_licensed_features(admin_audit_log: true)
    end

    it 'has Audit Log button in head nav bar' do
      visit admin_audit_logs_path

      expect(page).to have_link('Audit Log', href: admin_audit_logs_path)
    end

    describe 'release created events' do
      let(:project) { create(:project) }
      let(:release) { create(:release, project: project, tag: 'v0.1', author: user) }

      before do
        EE::AuditEvents::ReleaseCreatedAuditEventService.new(user, project, '127.0.0.1', release).security_event
      end

      it 'shows the related audit event' do
        visit admin_audit_logs_path

        expect(page).to have_content('Created Release')
      end
    end

    describe 'user events' do
      before do
        AuditEventService.new(user, user, with: :ldap)
          .for_authentication.security_event

        visit admin_audit_logs_path
      end

      it 'filters by user' do
        filter_by_type('User Events')

        click_button 'Search users'
        wait_for_requests

        within '.dropdown-menu-user' do
          click_link user.name
        end

        wait_for_requests

        expect(page).to have_content('Signed in with LDAP authentication')
      end
    end

    describe 'group events' do
      let(:group_member) { create(:group_member, user: user) }

      before do
        AuditEventService.new(user, group_member.group, { action: :create })
          .for_member(group_member).security_event

        visit admin_audit_logs_path
      end

      it 'filters by group' do
        filter_by_type('Group Events')

        find('.group-item-select').click
        wait_for_requests
        find('.select2-results').click

        find('#events-table td', match: :first)

        expect(page).to have_content('Added user access as Owner')
      end
    end

    describe 'project events' do
      let(:project_member) { create(:project_member, user: user) }
      let(:project) { project_member.project }

      before do
        AuditEventService.new(user, project, { action: :destroy })
          .for_member(project_member).security_event

        visit admin_audit_logs_path
      end

      it 'filters by project' do
        filter_by_type('Project Events')

        find('.project-item-select').click
        wait_for_requests
        find('.select2-results').click

        find('#events-table td', match: :first)

        expect(page).to have_content('Removed user access')
      end
    end

    describe 'filter by date', js: false do
      let_it_be(:audit_event_1) { create(:user_audit_event, created_at: 5.days.ago) }
      let_it_be(:audit_event_2) { create(:user_audit_event, created_at: 3.days.ago) }
      let_it_be(:audit_event_3) { create(:user_audit_event, created_at: 1.day.ago) }

      it 'shows only 2 days old events' do
        visit admin_audit_logs_path(created_after: 4.days.ago.to_date, created_before: 2.days.ago.to_date)

        expect(page).to have_content(audit_event_2.present.date)
        expect(page).not_to have_content(audit_event_1.present.date)
        expect(page).not_to have_content(audit_event_3.present.date)
      end

      it 'shows only yesterday events' do
        visit admin_audit_logs_path(created_after: 2.days.ago.to_date)

        expect(page).to have_content(audit_event_3.present.date)
        expect(page).not_to have_content(audit_event_1.present.date)
        expect(page).not_to have_content(audit_event_2.present.date)
      end

      it 'shows a message if provided date is invalid' do
        visit admin_audit_logs_path(created_after: '12-345-6789')

        expect(page).to have_content('Invalid date format. Please use UTC format as YYYY-MM-DD')
      end
    end
  end

  def filter_by_type(type)
    click_button 'All Events'

    within '.dropdown-menu-type' do
      click_link type
    end

    wait_for_requests
  end
end
