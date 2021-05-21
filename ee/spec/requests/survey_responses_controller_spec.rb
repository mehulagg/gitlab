# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SurveyResponsesController do
  describe 'GET #index' do
    before do
      allow(::Gitlab).to receive(:dev_env_or_com?).and_return(ondotcom)
    end

    subject(:request) { get survey_responses_path(params) }

    let(:ondotcom) { false }
    let(:params) do
      {
        survey_id: '123',
        instance_id: 'foo',
        response: 'response text',
        bla: 'bar',
        show_invite_link: 'true',
        onboarding_progress: '4'
      }
    end

    describe 'tracking a snowplow event', :snowplow do
      it 'does not track a survey_response event' do
        request

        expect_no_snowplow_event
      end

      context 'when on GitLab.com' do
        let(:ondotcom) { true }

        it 'tracks a survey_response event' do
          request

          expect_snowplow_event(
            category: described_class.name,
            action: 'submit_response',
            context: [
              {
                schema: described_class::SURVEY_RESPONSE_SCHEMA_URL,
                data:
                {
                  survey_id: 123,
                  response: 'response text',
                  onboarding_progress: 4
                }
              }
            ]
          )

          match_snowplow_context_schema(schema_path: 'survey_response_schema', context: { response: 'response text', survey_id: 123, onboarding_progress: 4 } )
        end
      end
    end

    describe 'invite link' do
      let(:ondotcom) { true }
      let(:feature_flag_enabled) { true }

      before do
        stub_feature_flags(calendly_invite_link: feature_flag_enabled)
        request
      end

      it { expect(assigns(:invite_link)).to eq(described_class::CALENDLY_INVITE_LINK) }

      context 'when not on gitlab.com' do
        let(:ondotcom) { false }

        it { expect(assigns(:invite_link)).to be_nil }
      end

      context "when the 'calendly_invite_link' feature flag is disabled" do
        let(:feature_flag_enabled) { false }

        it { expect(assigns(:invite_link)).to be_nil }
      end

      context "when the 'invite_link' parameter is not present in the URL" do
        let(:params) { }

        it { expect(assigns(:invite_link)).to be_nil }
      end
    end
  end
end
