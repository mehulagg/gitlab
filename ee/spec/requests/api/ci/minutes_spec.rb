# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Ci::Minutes do
  describe 'POST /namespaces/:id/minutes' do
    let_it_be(:namespace) { create(:namespace) }
    let_it_be(:user) { create(:user) }

    let(:namespace_id) { namespace.id }
    let(:payload) do
      {
        number_of_minutes: 10_000,
        expires_at: (Date.current + 1.year).to_s,
        purchase_xid: SecureRandom.hex(16)
      }
    end

    subject(:post_minutes) { post api("/namespaces/#{namespace_id}/minutes", user), params: payload }

    context 'with insufficient access' do
      it 'returns an error' do
        post_minutes

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'with admin user' do
      let_it_be(:user) { create(:admin) }

      context 'when the namespace cannot be found' do
        let(:namespace_id) { non_existing_record_id }

        it 'returns an error' do
          post_minutes

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'when the additional pack does not exist' do
        it 'creates a new additional pack', :aggregate_failures do
          expect { post_minutes }.to change(Ci::Minutes::AdditionalPack, :count).by(1)

          expect(response).to have_gitlab_http_status(:success)
          expect(json_response['number_of_minutes']).to eq payload[:number_of_minutes]
          expect(json_response['expires_at']).to eq payload[:expires_at]
          expect(json_response['purchase_xid']).to eq payload[:purchase_xid]
          expect(json_response['namespace_id']).to eq namespace_id
        end
      end

      context 'when the additional pack already exists' do
        before do
          create(:ci_minutes_additional_pack, purchase_xid: payload[:purchase_xid], namespace: namespace, number_of_minutes: 20_000)
        end

        it 'does not create a new additional pack and does not update the existing pack' do
          expect { post_minutes }.not_to change(Ci::Minutes::AdditionalPack, :count)

          expect(response).to have_gitlab_http_status(:success)
          expect(json_response['number_of_minutes']).not_to eq 10_0000
        end
      end

      context 'when the additional pack cannot be saved' do
        it 'returns an error' do
          allow_next_instance_of(Ci::Minutes::AdditionalPack) do |instance|
            allow(instance).to receive(:save).and_return false
          end

          post_minutes

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(response.body).to include('Unable to save additional pack')
        end
      end
    end
  end
end
