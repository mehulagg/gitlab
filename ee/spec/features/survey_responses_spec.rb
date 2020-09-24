# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Responses' do
  it 'Shows a friendly message' do
    visit survey_responses_path

    expect(page).to have_text _('Thank you for your feedback!')
  end
end
