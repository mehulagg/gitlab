# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Customizable Group Value Stream Analytics', :js do
  include DragTo
  include CycleAnalyticsHelpers

  let_it_be(:group) { create(:group, name: 'CA-test-group') }
  let_it_be(:sub_group) { create(:group, name: 'CA-sub-group', parent: group) }
  let_it_be(:group2) { create(:group, name: 'CA-bad-test-group') }
  let_it_be(:project) { create(:project, :repository, namespace: group, group: group, name: 'Cool fun project') }
  let_it_be(:group_label1) { create(:group_label, group: group) }
  let_it_be(:group_label2) { create(:group_label, group: group) }
  let_it_be(:label) { create(:group_label, group: group2) }
  let_it_be(:sub_group_label1) { create(:group_label, group: sub_group) }
  let_it_be(:sub_group_label2) { create(:group_label, group: sub_group) }
  let_it_be(:user) do
    create(:user).tap do |u|
      group.add_owner(u)
      project.add_maintainer(u)
    end
  end

  let(:milestone) { create(:milestone, project: project) }
  let(:mr) { create_merge_request_closing_issue(user, project, issue, commit_message: "References #{issue.to_reference}") }
  let(:pipeline) { create(:ci_empty_pipeline, status: 'created', project: project, ref: mr.source_branch, sha: mr.source_branch_sha, head_pipeline_of: mr) }

  let(:stage_nav_selector) { '.stage-nav' }
  let(:duration_stage_selector) { '.js-dropdown-stages' }

  custom_stage_name = 'Cool beans'
  custom_stage_with_labels_name = 'Cool beans - now with labels'
  start_event_identifier = :merge_request_created
  end_event_identifier = :merge_request_merged
  start_event_text = "Merge request created"
  end_event_text = "Merge request merged"
  start_label_event = :issue_label_added
  end_label_event = :issue_label_removed
  start_event_field = 'custom-stage-start-event-0'
  end_event_field = 'custom-stage-end-event-0'
  start_field_label = 'custom-stage-start-event-label-0'
  end_field_label = 'custom-stage-end-event-label-0'
  name_field = 'custom-stage-name-0'

  let(:add_stage_button) { '.js-add-stage-button' }
  let(:params) { { name: custom_stage_name, start_event_identifier: start_event_identifier, end_event_identifier: end_event_identifier } }
  let(:first_default_stage) { page.find('.stage-nav-item-cell', text: 'Issue').ancestor('.stage-nav-item') }
  let(:first_custom_stage) { page.find('.stage-nav-item-cell', text: custom_stage_name).ancestor('.stage-nav-item') }
  let(:nav) { page.find(stage_nav_selector) }

  def create_custom_stage(parent_group = group)
    Analytics::CycleAnalytics::Stages::CreateService.new(parent: parent_group, params: params, current_user: user).execute
  end

  def toggle_more_options(stage)
    stage.hover

    find_stage_actions_btn(stage).click
  end

  def select_dropdown_option(name, value = start_event_identifier)
    toggle_dropdown name
    page.find("[data-testid='#{name}'] .dropdown-menu").all('.dropdown-item').find { |item| item.value == value.to_s }.click
  end

  def select_dropdown_label(field, index = 1)
    page.find("[data-testid='#{field}'] .dropdown-menu").all('.dropdown-item')[index].click
  end

  def drag_from_index_to_index(from, to)
    drag_to(selector: '.stage-nav>ul',
            from_index: from,
            to_index: to)
  end

  def find_stage_actions_btn(stage)
    stage.find('[data-testid="more-actions-toggle"]')
  end

  before do
    stub_licensed_features(cycle_analytics_for_groups: true, type_of_work_analytics: true)

    sign_in(user)
  end

  shared_examples 'submits custom stage form successfully' do |stage_name|
    it 'custom stage is saved with confirmation message' do
      fill_in name_field, with: stage_name
      click_button(s_('CustomCycleAnalytics|Add stage'))

      expect(page.find('.flash-notice')).to have_text(_("Your custom stage '%{title}' was created") % { title: stage_name })
      expect(page).to have_selector('.stage-nav-item', text: stage_name)
    end
  end

  shared_examples 'can create custom stages' do
    context 'Custom stage form' do
      let(:show_form_add_stage_button) { '.js-add-stage-button' }

      before do
        page.find(show_form_add_stage_button).click
        wait_for_requests
      end

      context 'with empty fields' do
        it 'submit button is disabled by default' do
          expect(page).to have_button(s_('CustomCycleAnalytics|Add stage'), disabled: true)
        end
      end

      context 'with all required fields set' do
        before do
          fill_in name_field, with: custom_stage_name
          select_dropdown_option start_event_field, start_event_identifier
          select_dropdown_option end_event_field, end_event_identifier
        end

        it 'does not have label dropdowns' do
          expect(page).not_to have_content(s_('CustomCycleAnalytics|Start event label'))
          expect(page).not_to have_content(s_('CustomCycleAnalytics|End event label'))
        end

        it 'submit button is disabled if a default name is used' do
          fill_in name_field, with: 'issue'

          expect(page).to have_button(s_('CustomCycleAnalytics|Add stage'), disabled: true)
        end

        it 'submit button is disabled if the start event changes' do
          select_dropdown_option start_event_field, 'issue_created'

          expect(page).to have_button(s_('CustomCycleAnalytics|Add stage'), disabled: true)
        end

        include_examples 'submits custom stage form successfully', custom_stage_name
      end

      context 'with label based stages selected' do
        before do
          fill_in name_field, with: custom_stage_with_labels_name
          select_dropdown_option_by_value start_event_field, start_label_event
          select_dropdown_option_by_value end_event_field, end_label_event
        end

        it 'submit button is disabled' do
          expect(page).to have_button(s_('CustomCycleAnalytics|Add stage'), disabled: true)
        end

        context 'with labels available' do
          it 'does not contain labels from outside the group' do
            toggle_dropdown(start_field_label)
            menu = page.find("[data-testid=#{start_field_label}] .dropdown-menu")

            expect(menu).not_to have_content(other_label.name)
            expect(menu).to have_content(first_label.name)
            expect(menu).to have_content(second_label.name)
          end

          context 'with all required fields set' do
            before do
              toggle_dropdown(start_field_label)
              select_dropdown_label start_field_label, 0

              toggle_dropdown(end_field_label)
              select_dropdown_label end_field_label, 1
            end

            include_examples 'submits custom stage form successfully', custom_stage_with_labels_name
          end
        end
      end
    end
  end

  shared_examples 'can edit custom stages' do
    context 'Edit stage form' do
      let(:stage_form_class) { '.custom-stage-form' }
      let(:stage_save_button) { '[data-testid="save-custom-stage"]' }
      let(:updated_custom_stage_name) { 'Extra uber cool stage' }

      before do
        toggle_more_options(first_custom_stage)
        click_button(_('Edit stage'))
      end

      context 'with no changes to the data' do
        it 'prepopulates the stage data and disables submit button' do
          expect(page.find(stage_form_class)).to have_text(s_('CustomCycleAnalytics|Editing stage'))
          expect(page.find("[name='#{name_field}']").value).to eq custom_stage_name
          expect(page.find("[data-testid='#{start_event_field}']")).to have_text(start_event_text)
          expect(page.find("[data-testid='#{end_event_field}']")).to have_text(end_event_text)

          expect(page.find(stage_save_button)[:disabled]).to eq 'true'
        end
      end

      context 'with changes' do
        it 'persists updates to the stage' do
          fill_in name_field, with: updated_custom_stage_name
          page.find(stage_save_button).click

          expect(page.find('.flash-notice')).to have_text(_('Stage data updated'))
          expect(page.find(stage_nav_selector)).not_to have_text custom_stage_name
          expect(page.find(stage_nav_selector)).to have_text updated_custom_stage_name
        end

        it 'disables the submit form button if incomplete' do
          fill_in name_field, with: ''

          expect(page.find(stage_save_button)[:disabled]).to eq 'true'
        end

        it 'doesnt update the stage if a default name is provided' do
          fill_in name_field, with: 'issue'
          page.find(stage_save_button).click

          expect(page.find(stage_form_class)).to have_text(s_('CustomCycleAnalytics|Stage name already exists'))
        end
      end
    end
  end
end
