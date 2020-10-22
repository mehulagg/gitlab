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

      it 'tracks a survey_response event' do
        expect(controller).to receive(:track_self_describing_event).with(
          SurveyResponsesController::SURVEY_RESPONSE_SCHEMA_URL,
          survey_id: 1,
          response: 'bar'
        )

        subject
      end
    end

    context 'not on GitLab.com' do
      it 'does not track a survey_response event' do
        expect(controller).not_to receive(:track_self_describing_event)

        subject
      end
    end
  end
end
