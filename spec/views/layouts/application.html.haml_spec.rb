# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/application' do
  let(:user) { create(:user) }

  before do
    allow(view).to receive(:current_application_settings).and_return(Gitlab::CurrentSettings.current_application_settings)
    allow(view).to receive(:experiment_enabled?).and_return(false)
    allow(view).to receive(:session).and_return({})
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_user_mode).and_return(Gitlab::Auth::CurrentUserMode.new(user))
  end

  context 'body data elements for pageview context' do
    let(:body_data) do
      {
        body_data_page: 'projects:issues:show',
        body_data_page_type_id: '1',
        body_data_project_id: '2',
        body_data_namespace_id: '3'
      }
    end

    before do
      allow(view).to receive(:body_data).and_return(body_data)
      render
    end

    it 'includes the body element page' do
      expect(rendered).to include('data-page="projects:issues:show"')
    end

    it 'includes the body element page_type_id' do
      expect(rendered).to include('data-page-type-id="1"')
    end

    it 'includes the body element project_id' do
      expect(rendered).to include('data-project-id="2"')
    end

    it 'includes the body element namespace_id' do
      expect(rendered).to include('data-namespace-id="3"')
    end
  end

  describe 'layouts/_user_notification_dot' do
    let(:track_selector) { '[data-track-event="render"][data-track-label="show_buy_ci_minutes_notification"]' }
    let(:show_notification_dot) { false }

    before do
      allow(view).to receive(:show_pipeline_minutes_notification_dot?).and_return(show_notification_dot)
    end

    context 'when we show the notification dot' do
      let(:show_notification_dot) { true }

      before do
        allow(Gitlab).to receive(:com?) { true }
      end

      it 'has the notification dot' do
        render

        expect(rendered).to have_css('li', class: 'header-user') do
          expect(rendered).to have_css('span', class: 'notification-dot')
          expect(rendered).to have_selector(track_selector)
        end
      end
    end

    context 'when we do not show the notification dot' do
      it 'does not have the notification dot' do
        render

        expect(rendered).to have_css('li', class: 'header-user') do
          expect(rendered).not_to have_css('span', class: 'notification-dot')
          expect(rendered).not_to have_selector(track_selector)
        end
      end
    end
  end
end
