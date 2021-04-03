# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Multiple value streams', :js do
  include CycleAnalyticsHelpers

  let_it_be(:group) { create(:group, name: 'CA-test-group') }
  let_it_be(:project) { create(:project, :repository, namespace: group, group: group, name: 'Cool fun project') }
  let_it_be(:user) do
    create(:user).tap do |u|
      group.add_owner(u)
      project.add_maintainer(u)
    end
  end

  let(:value_stream_selector) { '[data-testid="dropdown-value-streams"]' }
  let(:extended_form_fields_selector) { '[data-testid="extended-form-fields"]' }
  let(:custom_value_stream_name) { "New created value stream" }
  let(:value_stream_dropdown) { page.find(value_stream_selector) }
  let!(:default_value_stream) { create(:cycle_analytics_group_value_stream, group: group, name: 'default') }

  3.times do |i|
    let_it_be("issue_#{i}".to_sym) { create(:issue, title: "New Issue #{i}", project: project, created_at: 2.days.ago) }
  end

  before do
    stub_licensed_features(cycle_analytics_for_groups: true, type_of_work_analytics: true)

    sign_in(user)
  end

  def toggle_value_stream_dropdown
    value_stream_dropdown.click
  end

  def select_value_stream(value_stream_name)
    toggle_value_stream_dropdown

    page.find('[data-testid="dropdown-value-streams"]').all('li button').find { |item| item.text == value_stream_name.to_s }.click
    wait_for_requests
  end

  def add_custom_stage_to_form
    page.find_button(s_('CreateValueStreamForm|Add another stage')).click

    index = page.all('[data-testid="value-stream-stage-fields"]').length
    last_stage = page.all('[data-testid="value-stream-stage-fields"]').last

    within last_stage do
      find('[name*="custom-stage-name-"]').fill_in with: "Cool custom stage - name #{index}"
      select_dropdown_option_by_value "custom-stage-start-event-", :merge_request_created
      select_dropdown_option_by_value "custom-stage-end-event-", :merge_request_merged
    end
  end

  def create_value_stream
    fill_in 'create-value-stream-name', with: custom_value_stream_name

    page.find_button(_('Create Value Stream')).click
    wait_for_requests
  end

  def create_custom_value_stream
    toggle_value_stream_dropdown
    page.find_button(_('Create new Value Stream')).click

    add_custom_stage_to_form
    create_value_stream
  end

  describe 'Create value stream' do
    before do
      select_group(group)

      toggle_value_stream_dropdown
      page.find_button(_('Create new Value Stream')).click
    end

    it 'includes additional form fields' do
      expect(page).to have_selector(extended_form_fields_selector)
    end

    it 'can create a value stream' do
      create_value_stream

      expect(page).to have_text(_("'%{name}' Value Stream created") % { name: custom_value_stream_name })
    end

    it 'can create a value stream with a custom stage and hidden defaults' do
      add_custom_stage_to_form

      # Hide some default stages
      page.find("[data-testid='stage-action-hide-5']").click
      page.find("[data-testid='stage-action-hide-3']").click
      page.find("[data-testid='stage-action-hide-1']").click

      create_value_stream

      expect(page).to have_text(_("'%{name}' Value Stream created") % { name: custom_value_stream_name })
      expect(page.find('[data-testid="gl-path-nav"]')).to have_text("Cool custom stage - name")
    end
  end

  describe 'Edit value stream' do
    before do
      select_group(group)

      create_custom_value_stream

      page.find_button(_('Edit')).click
    end

    it 'includes additional form fields' do
      expect(page).to have_selector(extended_form_fields_selector)
      expect(page).to have_button("Save Value Stream")
    end

    it 'can update the value stream name' do
      edited_name = "Edit new value stream"
      fill_in 'create-value-stream-name', with: edited_name

      page.find_button(_('Save Value Stream')).click
      wait_for_requests

      expect(page).to have_text(_("'%{name}' Value Stream saved") % { name: edited_name })
    end

    it 'can add a custom stage' do
      add_custom_stage_to_form

      page.find_button(_('Save Value Stream')).click
      wait_for_requests

      expect(page).to have_text(_("'%{name}' Value Stream saved") % { name: custom_value_stream_name })
    end
  end

  describe 'with the `value_stream_analytics_extended_form` feature flag disabled' do
    before do
      stub_licensed_features(cycle_analytics_for_groups: true, type_of_work_analytics: true)
      stub_feature_flags(value_stream_analytics_extended_form: false)

      sign_in(user)

      select_group(group)
      toggle_value_stream_dropdown

      page.find_button(_('Create new Value Stream')).click
    end

    it 'does not include additional form fields' do
      expect(page).not_to have_selector(extended_form_fields_selector)
    end

    it 'can create a value stream' do
      create_value_stream

      expect(page).to have_text(_("'%{name}' Value Stream created") % { name: custom_value_stream_name })
    end
  end

  describe 'Delete value stream' do
    before do
      value_stream = create(:cycle_analytics_group_value_stream, name: custom_value_stream_name, group: group)
      create(:cycle_analytics_group_stage, value_stream: value_stream)

      select_group(group)
    end

    it 'can delete a value stream' do
      select_value_stream(custom_value_stream_name)

      toggle_value_stream_dropdown

      page.find_button(_('Delete %{name}') % { name: custom_value_stream_name }).click
      page.find_button(_('Delete')).click
      wait_for_requests

      expect(page).to have_text(_("'%{name}' Value Stream deleted") % { name: custom_value_stream_name })
    end
  end
end
