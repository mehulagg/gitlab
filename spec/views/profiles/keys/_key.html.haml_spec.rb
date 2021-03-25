# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'profiles/keys/_key.html.haml' do
  let_it_be(:user) { create(:user) }

  before do
    allow(view).to receive(:key).and_return(key)
    allow(view).to receive(:is_admin).and_return(false)
  end

  context 'when the key partial is used' do
    let_it_be(:key) {
      create(:personal_key,
             user: user,
             last_used_at: 7.days.ago,
             expires_at: 2.days.from_now)
    }

    it 'displays the correct values', :aggregate_failures do
      render

      expect(rendered).to have_text(key.title)
      expect(rendered).to have_css('[data-testid="key-icon"]')
      expect(rendered).to have_text(key.fingerprint)
      expect(rendered).to have_text(l(key.last_used_at, format: "%b %d, %Y"))
      expect(rendered).to have_text(l(key.created_at, format: "%b %d, %Y"))
      expect(rendered).to have_text(key.expires_at.to_date)
      expect(response).to render_template(partial: 'shared/ssh_keys/_key_delete')
    end

    context 'when there is an error' do
      before do
        key.errors.add(:key, 'Error')
      end

      it 'shows the correct tooltip text' do
        render

        expect(rendered).to have_css('[data-testid="warning-solid-icon"]')
        expect(rendered).to have_selector('span.has-tooltip[title="Key Error"]')
      end
    end

    context 'when the key has not been used' do
      let_it_be(:key) {
        create(:personal_key,
               user: user,
               last_used_at: nil)
      }

      it 'renders "Never" for last used' do
        render

        expect(rendered).to have_text('Last used: Never')
      end
    end

    context 'when the key does not have an expiration date' do
      let_it_be(:key) {
        create(:personal_key,
               user: user,
               expires_at: nil)
      }

      it 'renders "Never" for expires' do
        render

        expect(rendered).to have_text('Expires: Never')
      end
    end

    context 'when the key is not deletable' do
      # Turns out key.can_delete? is only false for LDAP keys
      # However considering the generic nature of the Keys model
      # I've decided to keep this check in case we start making use of the method
      let_it_be(:key) { create(:ldap_key, user: user) }

      it 'does not render the partial' do
        render

        expect(response).not_to render_template(partial: 'shared/ssh_keys/_key_delete')
      end
    end

    context 'when expired' do
      let_it_be(:key) {
        create(:personal_key,
               user: user,
               expires_at: 2.days.ago)
      }

      context 'when expiration is enforced' do
        before do
          allow(Key).to receive(:expiration_enforced?).and_return(true)
        end

        it 'shows the correct tooltip text' do
          render

          expect(rendered).to have_css('[data-testid="warning-solid-icon"]')
          expect(rendered).to have_selector('span.has-tooltip[title="Key valid until deleted"]')
        end

        context 'when there is an error' do
          before do
            key.errors.add(:key, 'Error')
          end

          it 'shows the correct tooltip text' do
            render

            expect(rendered).to have_css('[data-testid="warning-solid-icon"]')
            expect(rendered).to have_selector('span.has-tooltip[title="Key valid until deleted"]')
          end
        end
      end

      context 'when expiration is not enforced' do
        before do
          allow(Key).to receive(:expiration_enforced?).and_return(false)
        end

        it 'shows the correct tooltip text' do
          render

          expect(rendered).to have_css('[data-testid="warning-solid-icon"]')
          expect(rendered).to have_selector('span.has-tooltip[title="Your key has expired"]')
        end

        context 'when there is an error' do
          before do
            key.errors.add(:key, 'Error')
          end

          it 'shows the correct tooltip text' do
            render

            expect(rendered).to have_css('[data-testid="warning-solid-icon"]')
            expect(rendered).to have_selector('span.has-tooltip[title="Your key has expired"]')
          end
        end
      end
    end
  end
end
