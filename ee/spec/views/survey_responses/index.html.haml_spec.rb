# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'survey_responses/index' do
  describe 'response page' do
    it 'shows a friendly message' do
      render

      expect(rendered).to have_content(_('Thank you for your feedback!'))
      expect(rendered).not_to have_content(_('We love speaking to our users. Got more to say about your GitLab experiences?'))
      expect(rendered).not_to have_link(_("Let's talk!"))
    end

    context 'when invite_link instance variable is set' do
      before do
        assign(:invite_link, SurveyResponsesController::CALENDLY_INVITE_LINK)
      end

      it 'shows additional text and an invite link' do
        render

        expect(rendered).to have_content(_('We love speaking to our users. Got more to say about your GitLab experiences?'))
        expect(rendered).to have_link(_("Let's talk!"), href: SurveyResponsesController::CALENDLY_INVITE_LINK)
      end
    end
  end
end
