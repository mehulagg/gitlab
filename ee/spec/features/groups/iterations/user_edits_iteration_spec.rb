# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User views iteration' do
  let_it_be(:now) { Time.now }
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:group_member, :maintainer, user: create(:user), group: group ).user }
  let_it_be(:guest_user) { create(:group_member, :guest, user: create(:user), group: group ).user }
  let_it_be(:iteration) { create(:iteration, :skip_future_date_validation, group: group, title: 'Correct Iteration', description: 'Iteration description', start_date: now - 1.day, due_date: now) }

  dropdown_selector = '[data-testid="actions-dropdown"]'

  context 'with license' do
    before do
      stub_licensed_features(iterations: true)
    end

    context 'as authorized user' do
      before do
        sign_in(user)
      end

      context 'load edit page directly', :js do
        before do
          visit edit_group_iteration_path(group, iteration.id)
        end

        it 'prefills fields and allows updating all values' do
          aggregate_failures do
            expect(title_input.value).to eq(iteration.title)
            expect(description_input.value).to eq(iteration.description)
            expect(start_date_input.value).to have_content(iteration.start_date)
            expect(due_date_input.value).to have_content(iteration.due_date)
          end

          updated_title = 'Updated iteration title'
          updated_desc = 'Updated iteration desc'
          updated_start_date = now + 4.days
          updated_due_date = now + 5.days

          fill_in('Title', with: updated_title)
          fill_in('Description', with: updated_desc)
          fill_in('Start date', with: updated_start_date.strftime('%Y-%m-%d'))
          fill_in('Due date', with: updated_due_date.strftime('%Y-%m-%d'))
          click_button('Update iteration')

          aggregate_failures do
            expect(page).to have_content(updated_title)
            expect(page).to have_content(updated_desc)
            expect(page).to have_content(updated_start_date.strftime('%b %-d, %Y'))
            expect(page).to have_content(updated_due_date.strftime('%b %-d, %Y'))
            expect(page).to have_current_path(group_iteration_path(group, iteration.id))
          end
        end
      end

      context 'load edit page from report', :js do
        before do
          visit group_iteration_path(iteration.group, iteration.id)
        end

        it 'prefills fields and updates URL' do
          find(dropdown_selector).click
          click_button('Edit iteration')

          aggregate_failures do
            expect(title_input.value).to eq(iteration.title)
            expect(description_input.value).to eq(iteration.description)
            expect(start_date_input.value).to have_content(iteration.start_date)
            expect(due_date_input.value).to have_content(iteration.due_date)
            expect(page).to have_current_path(edit_group_iteration_path(iteration.group, iteration.id))
          end
        end
      end
    end

    context 'as guest user' do
      before do
        sign_in(guest_user)
      end

      it 'does not show edit dropdown', :js do
        visit group_iteration_path(iteration.group, iteration.id)

        expect(page).to have_content(iteration.title)
        expect(page).not_to have_selector(dropdown_selector)
      end

      it '404s when loading edit page directly' do
        visit edit_group_iteration_path(iteration.group, iteration.id)

        expect(page).to have_gitlab_http_status(:not_found)
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
