# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User sees feature flag list', :js do
  include FeatureFlagHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }

  before_all do
    project.add_developer(user)
  end

  before do
    sign_in(user)
  end

  context 'with legacy feature flags' do
    before do
      create_flag(project, 'ci_live_trace', false).tap do |feature_flag|
        create_scope(feature_flag, 'review/*', true)
      end
      create_flag(project, 'drop_legacy_artifacts', false)
      create_flag(project, 'mr_train', true).tap do |feature_flag|
        create_scope(feature_flag, 'production', false)
      end
      stub_feature_flags(feature_flags_legacy_read_only_override: false)
    end

    context 'when legacy feature flags are not read-only' do
      before do
        stub_feature_flags(feature_flags_legacy_read_only: false)
      end

      it 'user updates the status toggle' do
        visit(project_feature_flags_path(project))

        within_feature_flag_row(1) do
          status_toggle_button.click

          expect_status_toggle_button_to_be_checked
        end

        visit(project_audit_events_path(project))

        expect(page).to(
          have_text('Updated feature flag ci_live_trace. Updated active from "false" to "true".')
        )
      end
    end

    context 'when legacy feature flags are read-only but the override is active for a project' do
      before do
        stub_feature_flags(
          feature_flags_legacy_read_only: true,
          feature_flags_legacy_read_only_override: project
        )
      end

      it 'user updates the status toggle' do
        visit(project_feature_flags_path(project))

        within_feature_flag_row(1) do
          status_toggle_button.click

          expect_status_toggle_button_to_be_checked
        end

        visit(project_audit_events_path(project))

        expect(page).to(
          have_text('Updated feature flag ci_live_trace. Updated active from "false" to "true".')
        )
      end
    end
  end

  context 'with new version flags' do
    before do
      create(:operations_feature_flag, :new_version_flag, project: project,
             name: 'my_flag', active: false)
    end

    it 'user updates the status toggle' do
      visit(project_feature_flags_path(project))

      within_feature_flag_row(1) do
        status_toggle_button.click

        expect_status_toggle_button_to_be_checked
      end

      visit(project_audit_events_path(project))

      expect(page).to(
        have_text('Updated feature flag my_flag. Updated active from "false" to "true".')
      )
    end
  end
end
