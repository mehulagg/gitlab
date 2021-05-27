# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Project settings > [EE] Merge Requests', :js do
  include GitlabRoutingHelper
  include FeatureApprovalHelper

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:group) { create(:group) }
  let_it_be(:group_member) { create(:user) }
  let_it_be(:non_member) { create(:user) }
  let_it_be(:config_selector) { '.js-status-checks-settings' }
  let_it_be(:modal_selector) { '#status-checks-create-modal' }

  before do
    sign_in(user)
    project.add_maintainer(user)
    group.add_developer(user)
    group.add_developer(group_member)
  end

  context 'Status checks' do
    context 'Feature is not available' do
      before do
        stub_licensed_features(compliance_approval_gates: false)
      end

      it 'should not render the status checks area' do
        expect(page).not_to have_selector('[data-qa-selector="status_checks_table"]')
      end
    end

    context 'Feature is available' do
      before do
        stub_licensed_features(compliance_approval_gates: true)
      end

      it 'adds a status check' do
        visit edit_project_path(project)

        click_button 'Add status check'

        within('.modal-content') do
          find('[data-qa-selector="rule_name_field"]').set('My new check')
          find('[data-qa-selector="external_url_field"]').set('https://api.gitlab.com')

          click_button 'Add status check'
        end

        wait_for_requests

        expect(find('[data-qa-selector="status_checks_table"]')).to have_content('My new check')
      end

      context 'with a status check' do
        let_it_be(:rule) { create(:external_approval_rule, project: project) }

        it 'updates the status check' do
          visit edit_project_path(project)

          expect(find('[data-qa-selector="status_checks_table"]')).to have_content(rule.name)

          within('[data-qa-selector="status_checks_table"]') do
            click_button 'Edit'
          end

          within('.modal-content') do
            find('[data-qa-selector="rule_name_field"]').set('Something new')

            click_button 'Update status check'
          end

          wait_for_requests

          expect(find('[data-qa-selector="status_checks_table"]')).to have_content('Something new')
        end

        it 'removes the status check' do
          visit edit_project_path(project)

          expect(find('[data-qa-selector="status_checks_table"]')).to have_content(rule.name)

          within('[data-qa-selector="status_checks_table"]') do
            click_button 'Remove...'
          end

          within('.modal-content') do
            click_button 'Remove status check'
          end

          wait_for_requests

          expect(find('[data-qa-selector="status_checks_table"]')).not_to have_content(rule.name)
        end
      end
    end
  end

  context 'Issuable default templates' do
    context 'Feature is not available' do
      before do
        stub_licensed_features(issuable_default_templates: false)
      end

      it 'input to configure merge request template is not shown' do
        visit edit_project_path(project)

        expect(page).not_to have_selector('#project_merge_requests_template')
      end

      it "does not mention the merge request template in the section's description text" do
        visit edit_project_path(project)

        expect(page).to have_content('Choose your merge method, merge options, merge checks, and merge suggestions.')
      end
    end

    context 'Feature is available' do
      before do
        stub_licensed_features(issuable_default_templates: true)
      end

      it 'input to configure merge request template is shown' do
        visit edit_project_path(project)

        expect(page).to have_selector('#project_merge_requests_template')
      end

      it "mentions the merge request template in the section's description text" do
        visit edit_project_path(project)

        expect(page).to have_content('Choose your merge method, merge options, merge checks, merge suggestions, and set up a default description template for merge requests.')
      end
    end
  end
end
