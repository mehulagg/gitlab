# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SurveyResponsesController do
  describe 'GET #index' do
    subject { get :index, params: params }

    let(:params) do
      {
        survey_id: '1',
        instance_id: 'foo',
        response: 'bar',
        bla: 'bla'
      }
    end

    context 'on GitLab.com' do
      before do
        allow(::Gitlab).to receive(:com?).and_return(true)
      end

      it 'tracks a survey_response event', :snowplow do
        subject

        expect_snowplow_event(
          category: described_class.name,
          action: 'submit_response',
          context: [{ schema: described_class::SURVEY_RESPONSE_SCHEMA_URL, data: { response: 'bar', survey_id: 1 } }]
        )
      end
    end

    context 'not on GitLab.com' do
      it 'does not track a survey_response event', :snowplow do
        subject

        expect_no_snowplow_event
      end
    end
  end
end
