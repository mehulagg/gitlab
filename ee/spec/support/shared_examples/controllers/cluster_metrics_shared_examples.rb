# frozen_string_literal: true

RSpec.shared_examples 'cluster metrics' do
  include AccessMatchersForController

  describe 'GET #metrics' do
    before do
      allow(controller).to receive(:prometheus_adapter).and_return(prometheus_adapter)
    end

    describe 'functionality' do
      before do
        sign_in(user)
      end

      context 'can query Prometheus' do
        let(:prometheus_adapter) { double(:prometheus_adapter, can_query?: true, query: nil) }

        it 'queries cluster metrics' do
          go

          expect(prometheus_adapter).to have_received(:query).with(:cluster)
        end

        context 'when response has content' do
          let(:query_response) { { non_empty: :response } }

          before do
            allow(prometheus_adapter).to receive(:query).and_return(query_response)
          end

          it 'returns prometheus query response' do
            go

            expect(response).to have_gitlab_http_status(:ok)
            expect(response.body).to eq(query_response.to_json)
          end
        end

        context 'when response has no content' do
          let(:query_response) { nil }

          before do
            allow(prometheus_adapter).to receive(:query).and_return(query_response)
          end

          it 'returns prometheus query response' do
            go

            expect(response).to have_gitlab_http_status(:no_content)
          end
        end
      end

      context 'without Prometheus' do
        let(:prometheus_adapter) { nil }

        it 'returns not found' do
          go

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'cannot query Prometheus' do
        let(:prometheus_adapter) { double(:prometheus_adapter, can_query?: false) }

        it 'returns not found' do
          go

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end

  private

  def go
    get :metrics, params: metrics_params, format: :json
  end
end
