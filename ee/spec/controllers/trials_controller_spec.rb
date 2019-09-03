# frozen_string_literal: true

require 'spec_helper'

describe TrialsController do
  shared_examples 'an authenticated endpoint' do |verb, action|
    it 'redirects to login page' do
      send(verb, action)

      expect(response).to redirect_to(new_trial_registration_url)
    end
  end

  describe '#new' do
    it_behaves_like 'an authenticated endpoint', :get, :new
  end

  describe '#create_lead' do
    it_behaves_like 'an authenticated endpoint', :post, :create_lead

    describe 'authenticated' do
      let(:user) { create(:user) }
      let(:create_lead_result) { nil }

      before do
        sign_in(user)

        expect_any_instance_of(GitlabSubscriptions::CreateLeadService).to receive(:execute) do
          { success: create_lead_result }
        end
      end

      context 'on success' do
        let(:create_lead_result) { true }

        it 'returns a successful 200 response' do
          post :create_lead

          expect(response).to have_gitlab_http_status(200)
        end
      end

      context 'on failure' do
        let(:create_lead_result) { false }

        it 'returns a unprocessable entity 422 response' do
          post :create_lead

          expect(response).to have_gitlab_http_status(422)
        end
      end
    end
  end
end
