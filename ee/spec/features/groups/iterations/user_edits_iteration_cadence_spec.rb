# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User edits iteration cadence', :js do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:group_member, :maintainer, user: create(:user), group: group ).user }
  let_it_be(:guest_user) { create(:group_member, :guest, user: create(:user), group: group ).user }
  let_it_be(:cadence) { create(:iterations_cadence, group: group) }

  dropdown_selector = '[data-testid="actions-dropdown"]'

  context 'with license' do
    before do
      stub_licensed_features(iterations: true)
    end

    context 'as guest user' do
      before do
        sign_in(guest_user)
      end

      it 'does not show edit dropdown' do
        visit group_iteration_cadences_path(cadence.group)

        expect(page).to have_content(cadence.title)
        expect(page).not_to have_selector(dropdown_selector)
      end

      it 'redirects to list page when loading edit page directly' do
        visit edit_group_iteration_cadence_path(cadence.group, id: cadence.id)

        # vue-router has trailing slash but _path helper doesn't
        expect(page).to have_current_path("#{group_iteration_cadences_path(cadence.group)}/")
      end
    end

    def title_input
      page.find('#iteration-title')
    end

    def description_input
      page.find('#iteration-description')
    end

    def start_date_input
      page.find('#iteration-start-date')
    end

    def due_date_input
      page.find('#iteration-due-date')
    end
  end
end
