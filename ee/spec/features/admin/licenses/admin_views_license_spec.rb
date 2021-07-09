# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin views license' do
  before do
    admin = create(:admin)

    sign_in(admin)
    gitlab_enable_admin_mode_sign_in(admin)
  end

  it 'gets redirected to the new subscription page' do
    visit(admin_license_path)

    expect(page).to have_current_path(admin_subscription_path)
  end
end
