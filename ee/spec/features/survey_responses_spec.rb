# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Responses' do
  it 'shows a friendly message' do
    visit survey_responses_path

    expect(page).to have_text _('Thank you for your feedback!')
    expect(page).not_to have_link _("Let's talk!")
  end

  describe "when the 'cta_talk' parameter is present in the URL and we are on GitLab.com" do
    before do
      allow(Gitlab).to receive(:com?).and_return(true)
    end

    it 'shows additional text and a link' do
      visit survey_responses_path(talk_cta: true)

      expect(page).to have_text _('We love speaking to our users. Got more to say about your GitLab experiences?')
      expect(page).to have_link _("Let's talk!")
    end
  end
end
