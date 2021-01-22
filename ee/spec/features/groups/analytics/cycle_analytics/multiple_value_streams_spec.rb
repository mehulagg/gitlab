# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Multiple value streams', :js do
  let_it_be(:group) { create(:group, name: 'CA-test-group') }
  let_it_be(:project) { create(:project, :repository, namespace: group, group: group, name: 'Cool fun project') }
  let_it_be(:user) do
    create(:user).tap do |u|
      group.add_owner(u)
      project.add_maintainer(u)
    end
  end

  value_stream_selector = '[data-testid="dropdown-value-streams"]'

  let(:value_stream_dropdown) { page.find(value_stream_selector) }
  let!(:default_value_stream) { create(:cycle_analytics_group_value_stream, group: group, name: 'default') }

  3.times do |i|
    let_it_be("issue_#{i}".to_sym) { create(:issue, title: "New Issue #{i}", project: project, created_at: 2.days.ago) }
  end

  def select_group(target_group = group)
    visit group_analytics_cycle_analytics_path(target_group)

    expect(page).to have_selector '.js-stage-table' # wait_for_stages_to_load
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

  describe 'Create value stream' do
    before do
      select_group

      wait_for_requests
    end

    it 'can create a value stream' do
      custom_value_stream_name = "New created value stream"
      toggle_value_stream_dropdown

      page.find_button(_('Create new Value Stream')).click

      fill_in 'create-value-stream-name', with: custom_value_stream_name
      page.find_button(_('Create Value Stream')).click
      wait_for_requests

      expect(page).to have_text(_("'%{name}' Value Stream created") % { name: custom_value_stream_name })
    end
  end

  describe 'Delete value stream' do
    let(:custom_value_stream_name) { "Test value stream" }

    before do
      value_stream = create(:cycle_analytics_group_value_stream, name: custom_value_stream_name, group: group)
      create(:cycle_analytics_group_stage, value_stream: value_stream)

      select_group

      wait_for_requests
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
