# frozen_string_literal: true

require 'securerandom'

module QA
  RSpec.describe 'Fulfillment', only: { subdomain: :staging } do
    describe 'Purchase' do
      let(:user) do
        Resource::User.fabricate_via_api! do |user|
          user.email = "gitlab-qa+#{SecureRandom.hex(2)}@gitlab.com"
        end
      end

      let(:last_name) { 'Test' }
      let(:company_name) { 'QA Test Company' }
      let(:number_of_employees) { '500 - 1,999' }
      let(:telephone_number) { '555-555-5555' }
      let(:how_many_users) { 600 }
      let(:country) { 'United States of America' }

      let(:group) { Resource::Group.fabricate_via_api! }

      before do
        group.add_member(user)
        Flow::Login.sign_in(as: user)
      end

      RSpec.shared_examples 'free trial' do
        it 'registers for a new trial' do
          Page::Trials::New.perform do |new|
            # setter
            new.company_name = company_name
            new.number_of_employees = number_of_employees
            new.telephone_number = telephone_number
            new.how_many_users = how_many_users
            new.country = country

            new.continue
          end

          Page::Trials::Select.perform do |select|
            select.subscription_for = group.name
            select.start_your_free_trial
          end

          Page::Main::Login.perform(&:login)

          Page::Alert::FreeTrial.perform do |free_trial_alert|
            expect(free_trial_alert.alert_message).to have_text('Congratulations, your free trial is activated')
          end
        end
      end

      describe 'starts a free trial' do
        context 'when on about page' do
          before do
            Runtime::Browser.visit(:about, Chemlab::Vendor::GitlabHandbook::Page::About)

            Chemlab::Vendor::GitlabHandbook::Page::About.perform(&:get_free_trial)

            # Clicking the link will force navigation away from `staging.gitlab.com` and to `gitlab.com`.  Instead,
            # we will navigate to the Page::Trials::New page while preserving the domain.
            # Chemlab::Vendor::GitlabHandbook::Page::FreeTrial.perform(&:start_your_gitlab_free_trial_saas)
            Page::Trials::New.perform(&:visit)
          end

          it_behaves_like 'free trial'
        end

        context 'when on billing page' do
          before do
            group.visit
            EE::Page::Group::Menu.perform(&:go_to_billing)
            Page::Group::Settings::Billing.perform(&:start_your_free_trial)
          end

          it_behaves_like 'free trial'
        end
      end
    end
  end
end
