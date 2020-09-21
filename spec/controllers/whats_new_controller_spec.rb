# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WhatsNewController do
  describe 'GET #index' do
    context 'when request is js' do
      it 'is successful' do
        allow(controller).to receive(:whats_new_most_recent_release_items).and_return('items')

        get :index, format: :js, xhr: true

        expect(response).to be_successful
      end
    end
  end
end
