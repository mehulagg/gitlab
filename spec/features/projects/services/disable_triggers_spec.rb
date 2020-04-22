# frozen_string_literal: true

require 'spec_helper'

describe 'Disable individual triggers' do
  include_context 'project service activation'

  let(:checkbox_selector) { 'input[type=checkbox][id$=_events]' }

  before do
    visit_project_integration(service_name)
  end

  context 'service has multiple supported events' do
    let(:service_name) { 'HipChat' }

    it 'shows trigger checkboxes' do
      event_count = HipchatService.supported_events.count

      expect(page).to have_content "Trigger"
      expect(page).to have_css(checkbox_selector, count: event_count)
    end
  end

  context 'services only has one supported event' do
    let(:service_name) { 'Asana' }

    it "doesn't show unnecessary Trigger checkboxes" do
      expect(page).not_to have_content "Trigger"
      expect(page).not_to have_css(checkbox_selector)
    end
  end
end
