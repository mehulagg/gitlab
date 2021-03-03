# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('shared/credentials_inventory/gpg_keys/_gpg_key.html.haml') do
  let_it_be(:user) { create(:user, email: GpgHelpers::User1.emails.first) }
  let_it_be(:gpg_key) { create(:gpg_key, user: user, key: GpgHelpers::User1.public_key) }

  before do
    allow(view).to receive(:user_detail_path).and_return('abcd')
    render 'shared/credentials_inventory/gpg_keys/gpg_key', gpg_key: gpg_key
  end

  it 'shows the users name' do
    expect(rendered).to have_text(user.name)
  end

  it 'shows the ID' do
    expect(rendered).to have_text(gpg_key.primary_keyid)
  end

  context 'shows the status' do
    it 'when the key is verified it shows the verified badge', :aggregate_failures do
      expect(rendered).to have_css('.badge-success')
      expect(rendered).to have_text('Verified')
    end

    context 'when the key is not verified' do
      let_it_be(:user) { create(:user, email: 'random@example.com') }
      let_it_be(:gpg_key) { create(:another_gpg_key, user: user) }

      it 'shows the unverified badge', :aggregate_failures do
        expect(rendered).to have_css('.badge-danger')
        expect(rendered).to have_text('Unverified')
      end
    end
  end
end
