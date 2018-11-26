# frozen_string_literal: true

module QA
  context 'Manage', :orchestrated, :ldap_no_tls, :ldap_tls do
    describe 'LDAP admin sync' do
      it 'Syncs admin users' do
        Runtime::Browser.visit(:gitlab, Page::Main::Login)

        Page::Main::Login.perform do |login_page|
          Runtime::Env.ldap_username = 'adminuser1'
          Runtime::Env.ldap_password = 'password'

          login_page.sign_in_using_credentials
        end

        Page::Main::Menu.perform do |menu|
          expect(menu).to have_personal_area

          # The ldap_sync_worker_cron job is set to run every minute
          admin_synchronised = menu.wait(max: 80, time: 1, reload: true) do
            menu.has_admin_area_link?
          end

          expect(admin_synchronised).to be_truthy
        end
      end
    end
  end
end
