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
  stage_table_selector = '.js-stage-table'

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

  context 'Manual ordering' do
    before do
      stub_feature_flags(value_stream_analytics_path_navigation: false)
      select_group(group, stage_table_selector)
    end

    let(:default_stage_order) { %w[Issue Plan Code Test Review Staging].freeze }

    def confirm_stage_order(stages)
      page.within('.stage-nav>ul') do
        stages.each_with_index do |stage, index|
          expect(find("li:nth-child(#{index + 1})")).to have_content(stage)
        end
      end
    end

    context 'with only default stages' do
      it 'does not allow stages to be draggable', :js do
        confirm_stage_order(default_stage_order)

        drag_from_index_to_index(0, 1)

        confirm_stage_order(default_stage_order)
      end
    end

    context 'with at least one custom stage', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/216745' do
      default_custom_stage_order = %w[Issue Plan Code Test Review Staging Cool\ beans].freeze
      stages_near_middle_swapped = %w[Issue Plan Test Code Review Staging Cool\ beans].freeze
      stage_dragged_to_top = %w[Review Issue Plan Code Test Staging Cool\ beans].freeze
      stage_dragged_to_bottom = %w[Issue Plan Code Test Staging Cool\ beans Review].freeze

      shared_examples 'draggable stage' do |original_order, updated_order, start_index, end_index,|
        before do
          page.driver.browser.manage.window.resize_to(1650, 1150)

          create_custom_stage
          select_group(group)
        end

        it 'allows a stage to be dragged' do
          confirm_stage_order(original_order)

          drag_from_index_to_index(start_index, end_index)

          confirm_stage_order(updated_order)
        end

        it 'persists the order when a group is selected' do
          drag_from_index_to_index(start_index, end_index)

          select_group(group)

          confirm_stage_order(updated_order)
        end
      end

      context 'dragging a stage to the top', :js do
        it_behaves_like 'draggable stage', default_custom_stage_order, stage_dragged_to_top, 4, 0
      end

      context 'dragging a stage to the bottom', :js do
        it_behaves_like 'draggable stage', default_custom_stage_order, stage_dragged_to_bottom, 4, 7
      end

      context 'dragging stages in the middle', :js do
        it_behaves_like 'draggable stage', default_custom_stage_order, stages_near_middle_swapped, 2, 3
      end
    end
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

  context 'With the path navigation feature flag disabled' do
    before do
      stub_feature_flags(value_stream_analytics_path_navigation: false)
    end

    context 'with a group' do
      context 'selected' do
        before do
          select_group(group, stage_table_selector)
        end

        it_behaves_like 'can create custom stages' do
          let(:first_label) { group_label1 }
          let(:second_label) { group_label2 }
          let(:other_label) { label }
        end
      end

      context 'with a custom stage created', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/273045' do
        before do
          create_custom_stage
          select_group(group, stage_table_selector)

          expect(page).to have_text custom_stage_name
        end

        it_behaves_like 'can edit custom stages'
      end
    end

    context 'with a sub group' do
      context 'selected' do
        before do
          select_group(sub_group, stage_table_selector)
        end

        it_behaves_like 'can create custom stages' do
          let(:first_label) { sub_group_label1 }
          let(:second_label) { sub_group_label2 }
          let(:other_label) { label }
        end
      end

      context 'with a custom stage created' do
        before do
          create_custom_stage(sub_group)
          select_group(sub_group, stage_table_selector)

          expect(page).to have_text custom_stage_name
        end

        it_behaves_like 'can edit custom stages'
      end
    end

    context 'Add a stage button' do
      before do
        stub_feature_flags(value_stream_analytics_path_navigation: false)
        select_group(group, stage_table_selector)
      end

      it 'displays the custom stage form when clicked' do
        expect(page).not_to have_text(s_('CustomCycleAnalytics|New stage'))

        expect(page).to have_selector(add_stage_button, visible: true)
        expect(page).to have_text(s_('CustomCycleAnalytics|Add a stage'))
        expect(page).not_to have_selector("#{add_stage_button}.active")

        page.find(add_stage_button).click

        expect(page).to have_selector("#{add_stage_button}.active")
        expect(page).to have_text(s_('CustomCycleAnalytics|New stage'))
      end
    end

    context 'default stages' do
      def open_recover_stage_dropdown
        find(add_stage_button).click
        click_button(_('Recover hidden stage'))
      end

      def active_stages
        page.all('.stage-nav .stage-name').collect(&:text)
      end

      before do
        stub_feature_flags(value_stream_analytics_path_navigation: false)
        select_group(group, stage_table_selector)

        toggle_more_options(first_default_stage)
      end

      it "can be hidden, can't be edited or removed" do
        expect(find_stage_actions_btn(first_default_stage)).to have_text(_('Hide stage'))
        expect(find_stage_actions_btn(first_default_stage)).not_to have_text(_('Edit stage'))
        expect(find_stage_actions_btn(first_default_stage)).not_to have_text(_('Remove stage'))
      end

      context 'Hide stage' do
        before do
          click_button(_('Hide stage'))

          # wait for the stage list to load
          expect(nav).to have_content(s_('CycleAnalyticsStage|Plan'))
        end

        it 'disappears from the stage table & can be recovered' do
          expect(active_stages).not_to include(s_('CycleAnalyticsStage|Issue'))

          open_recover_stage_dropdown

          expect(page.find("[data-testid='recover-hidden-stage-dropdown']")).to have_text(s_('CycleAnalyticsStage|Issue'))
        end
      end

      context 'Recover stage' do
        before do
          click_button(_('Hide stage'))

          # wait for the stage list to load
          expect(nav).to have_content(s_('CycleAnalyticsStage|Plan'))
        end

        it 'recovers the stage back to the stage table' do
          open_recover_stage_dropdown
          click_button(s_('CycleAnalyticsStage|Issue'))

          # wait for the stage list to load
          expect(nav).to have_content(s_('CycleAnalyticsStage|Plan'))

          expect(page.find('.flash-notice')).to have_content(_('Stage data updated'))
          expect(active_stages).to include(s_('CycleAnalyticsStage|Issue'))
        end
      end
    end

    context 'custom stages' do
      before do
        stub_feature_flags(value_stream_analytics_path_navigation: false)
        create_custom_stage
        select_group(group, stage_table_selector)

        expect(page).to have_text custom_stage_name

        toggle_more_options(first_custom_stage)
      end

      it 'can not be hidden, can be edited or removed' do
        expect(find_stage_actions_btn(first_custom_stage)).not_to have_text(_('Hide stage'))
        expect(find_stage_actions_btn(first_custom_stage)).to have_text(_('Edit stage'))
        expect(find_stage_actions_btn(first_custom_stage)).to have_text(_('Remove stage'))
      end

      it 'disappears from the stage table after being removed' do
        nav = page.find(stage_nav_selector)
        expect(nav).to have_text(custom_stage_name)

        click_button(_('Remove stage'))

        expect(page.find('.flash-notice')).to have_text(_('Stage removed'))
        expect(nav).not_to have_text(custom_stage_name)
      end
    end
  end

  context 'Duration chart' do
    let(:duration_chart_dropdown) { page.find(duration_stage_selector) }

    let_it_be(:translated_default_stage_names) do
      Gitlab::Analytics::CycleAnalytics::DefaultStages.names.map do |name|
        stage = Analytics::CycleAnalytics::GroupStage.new(name: name)
        Analytics::CycleAnalytics::StagePresenter.new(stage).title
      end.freeze
    end

    def duration_chart_stages
      duration_chart_dropdown.all('.dropdown-item').collect(&:text)
    end

    def toggle_duration_chart_dropdown
      duration_chart_dropdown.click
    end

    before do
      select_group(group)
    end

    it 'has all the default stages' do
      toggle_duration_chart_dropdown

      expect(duration_chart_stages).to eq(translated_default_stage_names)
    end

    context 'hidden stage' do
      before do
        stub_feature_flags(value_stream_analytics_path_navigation: false)
        select_group(group, stage_table_selector)
        toggle_more_options(first_default_stage)

        click_button(_('Hide stage'))

        # wait for the stage list to load
        expect(nav).to have_content(s_('CycleAnalyticsStage|Plan'))
      end

      it 'will not appear in the duration chart dropdown' do
        toggle_duration_chart_dropdown

        expect(duration_chart_stages).not_to include(s_('CycleAnalyticsStage|Issue'))
      end
    end
  end
end
