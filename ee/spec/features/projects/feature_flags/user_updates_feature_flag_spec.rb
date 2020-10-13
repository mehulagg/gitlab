# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User updates feature flag', :js do
  include FeatureFlagHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }

  before_all do
    project.add_developer(user)
  end

  before do
    stub_feature_flags(
      feature_flag_permissions: false,
      feature_flags_legacy_read_only_override: false
    )
    sign_in(user)
  end

  context 'with a legacy feature flag' do
    let!(:feature_flag) do
      create_flag(project, 'ci_live_trace', true,
                  description: 'For live trace feature')
    end

    let!(:scope) { create_scope(feature_flag, 'review/*', true) }

    context 'when legacy flags are editable' do
      before do
        stub_feature_flags(feature_flags_legacy_read_only: false)

        visit(edit_project_feature_flag_path(project, feature_flag))
      end

      context 'when user updates the status of a scope' do
        before do
          within_scope_row(2) do
            within_status { find('.project-feature-toggle').click }
          end

          click_button 'Save changes'
          expect(page).to have_current_path(project_feature_flags_path(project))
        end

        it 'records audit event' do
          visit(project_audit_events_path(project))

          expect(page).to(
            have_text("Updated feature flag ci_live_trace. Updated rule review/* active state from true to false.")
          )
        end
      end

      context 'when user adds a new scope' do
        before do
          within_scope_row(3) do
            within_environment_spec do
              find('.js-env-search > input').set('production')
              find('.js-create-button').click
            end
          end

          click_button 'Save changes'
          expect(page).to have_current_path(project_feature_flags_path(project))
        end

        it 'records audit event' do
          visit(project_audit_events_path(project))

          expect(page).to have_text "Updated feature flag ci_live_trace"
        end
      end

      context 'when user deletes a scope' do
        before do
          within_scope_row(2) do
            within_delete { find('.js-delete-scope').click }
          end

          click_button 'Save changes'
          expect(page).to have_current_path(project_feature_flags_path(project))
        end

        it 'records audit event' do
          visit(project_audit_events_path(project))

          expect(page).to have_text "Updated feature flag ci_live_trace"
        end
      end
    end
  end
end
