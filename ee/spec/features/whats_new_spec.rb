# frozen_string_literal: true

require "spec_helper"

RSpec.describe "renders a `whats new` dropdown item", :js do
  let_it_be(:user) { create(:user) }

  before do
    stub_feature_flags(whats_new_dropdown: true, whats_new_drawer: true)

    sign_in(user)
  end

  it 'shows notification count and removes it once viewed' do
    visit root_dashboard_path

    find('.header-help-dropdown-toggle').click

    page.within '.header-help' do
      expect(page).to have_button(text: "See what's new at GitLab")
      expect(page).to have_selector('.js-whats-new-notification-count')

      find('button', text: "See what's new at GitLab").click
    end

    find('.whats-new-drawer .gl-drawer-close-button').click
    find('.header-help-dropdown-toggle').click

    page.within '.header-help' do
      expect(page).to have_button(text: "See what's new at GitLab")
      expect(page).not_to have_selector('.js-whats-new-notification-count')
    end
  end
end
