# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Admin::Users" do
  include Spec::Support::Helpers::Features::ResponsiveTableHelpers

  let!(:user) do
    create(:omniauth_user, provider: 'twitter', extern_uid: '123456')
  end

  let!(:current_user) { create(:admin, last_activity_on: 5.days.ago) }

  before do
    stub_feature_flags(vue_admin_users: false)
    sign_in(current_user)
    gitlab_enable_admin_mode_sign_in(current_user)
  end

  describe 'GET /admin/users' do
    describe 'send emails to users' do
      context 'when `send_emails_from_admin_area` feature is enabled' do
        before do
          stub_licensed_features(send_emails_from_admin_area: true)
        end

        it "shows the 'Send email to users' link" do
          visit admin_users_path

          expect(page).to have_link(href: admin_email_path)
        end
      end

      context 'when `send_emails_from_admin_area` feature is disabled' do
        before do
          stub_licensed_features(send_emails_from_admin_area: false)
        end

        it "does not show the 'Send email to users' link" do
          visit admin_users_path

          expect(page).not_to have_link(href: admin_email_path)
        end
      end
    end

    describe 'user permission export' do
      context 'when `export_user_permissions` feature is available' do
        before do
          stub_licensed_features(export_user_permissions: true)
        end

        it "shows the 'Export Permissions' link" do
          visit admin_users_path

          expect(page).to have_link(href: admin_user_permission_exports_path(format: :csv))
        end
      end

      context 'when `export_user_permissions` feature is disabled' do
        before do
          stub_licensed_features(export_user_permissions: false)
        end

        it "does not show the 'Export Permissions' link" do
          visit admin_users_path

          expect(page).not_to have_link(href: admin_user_permission_exports_path(format: :csv))
        end
      end
    end
  end

  describe "GET /admin/users/:id" do
    describe 'Shared runners quota status' do
      before do
        user.namespace.update!(shared_runners_minutes_limit: 500)
      end

      context 'with projects with shared runners enabled' do
        before do
          create(:project, namespace: user.namespace, shared_runners_enabled: true)
        end

        it 'shows quota' do
          visit admin_users_path

          click_link user.name

          expect(page).to have_content('Pipeline minutes quota: 0 / 500')
        end
      end

      context 'without projects with shared runners enabled' do
        before do
          create(:project, namespace: user.namespace, shared_runners_enabled: false)
        end

        it 'does not show quota' do
          visit admin_users_path

          click_link user.name

          expect(page).not_to have_content('Pipeline minutes quota:')
        end
      end
    end
  end

  describe "GET /admin/users/:id/edit" do
    before do
      visit admin_users_path
      click_link "edit_user_#{user.id}"
    end

    describe "Update user account type" do
      before do
        allow_any_instance_of(AuditorUserHelper).to receive(:license_allows_auditor_user?).and_return(true)
        choose "user_access_level_auditor"
        click_button "Save changes"
      end

      it "changes account type to be auditor" do
        user.reload

        expect(user).not_to be_admin
        expect(user).to be_auditor
      end
    end

    describe 'Update shared runners quota' do
      let!(:project) { create(:project, namespace: user.namespace, shared_runners_enabled: true) }

      before do
        fill_in "user_namespace_attributes_shared_runners_minutes_limit", with: "500"
        click_button "Save changes"
      end

      it "shows page with new data" do
        expect(page).to have_content('Pipeline minutes quota: 0 / 500')
      end
    end
  end

  describe 'show user keys for SSH and LDAP' do
    let!(:key1) do
      create(:ldap_key, user: user, title: "LDAP Key1")
    end

    let!(:key2) do
      create(:key, user: user, title: "ssh-rsa Key2", key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4FIEBXGi4bPU8kzxMefudPIJ08/gNprdNTaO9BR/ndy3+58s2HCTw2xCHcsuBmq+TsAqgEidVq4skpqoTMB+Uot5Uzp9z4764rc48dZiI661izoREoKnuRQSsRqUTHg5wrLzwxlQbl1MVfRWQpqiz/5KjBC7yLEb9AbusjnWBk8wvC1bQPQ1uLAauEA7d836tgaIsym9BrLsMVnR4P1boWD3Xp1B1T/ImJwAGHvRmP/ycIqmKdSpMdJXwxcb40efWVj0Ibbe7ii9eeoLdHACqevUZi6fwfbymdow+FeqlkPoHyGg3Cu4vD/D8+8cRc7mE/zGCWcQ15Var83Tczour Key2")
    end

    it 'only shows the delete button for regular keys' do
      visit admin_users_path

      click_link user.name
      click_link 'SSH keys'

      # Check that the regular Key shows the delete icon and the LDAPKey does not

      # SSH key should be the first in the list
      within('ul.content-list li.key-list-item:nth-of-type(1)') do
        expect(page).to have_content(key2.title)
        expect(page).to have_button('Delete')
      end

      # Next, LDAP key
      within('ul.content-list li.key-list-item:nth-of-type(2)') do
        expect(page).to have_content(key1.title)
        expect(page).not_to have_button('Delete')
      end
    end
  end
end
