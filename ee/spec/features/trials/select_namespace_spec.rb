# frozen_string_literal: true

require 'spec_helper'

describe 'Trial Select Namespace', :js do
  include Select2Helper

  let(:new_group_name) { 'GitLab' }
  let(:user) { create(:user) }

  before do
    stub_feature_flags(improved_trial_signup: true)
    allow(Gitlab).to receive(:com?).and_return(true).at_least(:once)
    sign_in(user)
  end

  context 'when user' do
    context 'selects create a new group' do
      before do
        visit select_trials_path
        wait_for_all_requests

        select2 '0', from: '#namespace_id'
      end

      it 'shows the new group name input' do
        expect(page).to have_field('New Group Name')
      end

      context 'enters a valid new group name' do
        context 'when user can create groups' do
          before do
            expect_any_instance_of(GitlabSubscriptions::ApplyTrialService).to receive(:execute) do
              { success: true }
            end
          end

          it 'proceeds to the next step' do
            fill_in 'New Group Name', with: new_group_name

            click_button 'Start your free trial'

            wait_for_requests

            expect(page).not_to have_css('flash-container')
            expect(current_path).to eq('/gitlab')
          end
        end

        context 'when user can not create groups' do
          before do
            user.update_attribute(:can_create_group, false)
          end

          it 'returns 404' do
            fill_in 'New Group Name', with: new_group_name

            click_button 'Start your free trial'

            expect(page).to have_content('Page Not Found')
          end
        end
      end

      context 'enters an existing group name' do
        let!(:namespace) { create(:namespace, owner_id: user.id, path: 'gitlab') }

        it 'shows validation error' do
          fill_in 'New Group Name', with: namespace.path

          click_button 'Start your free trial'

          wait_for_requests

          expect(page).to have_selector('.flash-text')
          expect(find('.flash-alert')).to have_text('Group URL has already been taken')
          expect(current_path).to eq(apply_trials_path)
        end
      end

      context 'and does not enter a new group name' do
        it 'shows validation error' do
          click_button 'Start your free trial'

          message = page.find('#new_group_name').native.attribute('validationMessage')

          expect(message).to eq('Please fill out this field.')
          expect(current_path).to eq(select_trials_path)
        end
      end
    end

    context 'selects an existing group' do
      before do
        visit select_trials_path
        wait_for_all_requests

        select2 user.namespace.id, from: '#namespace_id'
      end

      context 'without trial plan' do
        it 'does not show the new group name input' do
          expect(page).not_to have_field('New Group Name')
        end

        it 'applies trial and redirects to dashboard' do
          expect_any_instance_of(GitlabSubscriptions::ApplyTrialService).to receive(:execute) do
            { success: true }
          end

          click_button 'Start your free trial'

          wait_for_requests

          expect(current_path).to eq("/#{user.namespace.path}")
        end
      end

      context 'with trial plan' do
        let!(:error_message) { 'Validation failed: Gl namespace can have only one trial' }

        it 'shows validation error' do
          expect_any_instance_of(GitlabSubscriptions::ApplyTrialService).to receive(:execute) do
            { success: false, errors: error_message }
          end

          click_button 'Start your free trial'

          expect(find('.flash-text')).to have_text(error_message)
          expect(current_path).to eq(apply_trials_path)

          # new group name should be functional
          select2 '0', from: '#namespace_id'

          expect(page).to have_field('New Group Name')
        end
      end
    end
  end
end
