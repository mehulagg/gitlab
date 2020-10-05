# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('shared/credentials_inventory/ssh_keys/_ssh_key.html.haml') do
  let_it_be(:user) { create(:user) }
  let_it_be(:expiry_date) { 20.days.since }
  let_it_be(:ssh_key) { create(:personal_key, user: user, expires_at: expiry_date)}

  before do
    allow(view).to receive(:user_detail_path).and_return('abcd')
    render 'shared/credentials_inventory/ssh_keys/ssh_key', ssh_key: ssh_key
  end

  it 'shows the users name' do
    expect(rendered).to have_text(user.name)
  end

  it 'shows the created on date' do
    expect(rendered).to have_text(ssh_key.created_at.to_date.to_s)
  end

  it 'shows the expiry date' do
    expect(rendered).to have_text(ssh_key.expires_at.to_date.to_s)
  end

  context 'last accessed date' do
    context 'when set' do
      let_it_be(:last_used_date) { 10.days.ago }
      let_it_be(:ssh_key) { create(:personal_key, user: user, last_used_at: last_used_date)}

      it 'shows the last accessed on date' do
        expect(rendered).to have_text(ssh_key.last_used_at.to_date.to_s)
      end
    end

    context 'when not set' do
      let_it_be(:ssh_key) { create(:personal_key, user: user)}

      it 'shows "Never" for the last accessed on date' do
        expect(rendered).to have_text('Last Accessed On Never')
      end
    end
  end
end
