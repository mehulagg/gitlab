# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SitemapController do
  describe '#show' do
    subject { get :show, format: :xml }

    before do
      allow(Gitlab).to receive(:com?).and_return(dot_com)
    end

    context 'when not Gitlab.com?' do
      let(:dot_com) { false }

      it 'returns :not_found' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when Gitlab.com?' do
      let(:dot_com) { true }

      context 'with an authenticated user' do
        let(:flag_value) { true }

        before do
          stub_feature_flags(gitlab_org_sitemap: flag_value)

          allow(Sitemap::CreateService).to receive_message_chain(:new, :execute).and_return(result)

          subject
        end

        shared_examples 'gitlab_org_sitemap flag is disabled' do
          let(:flag_value) { false }

          it 'returns :not_found' do
            expect(response).to have_gitlab_http_status(:not_found)
          end
        end

        context 'when the sitemap generation raises an error' do
          let(:result) { ServiceResponse.error(message: 'foo') }

          it 'returns an xml error' do
            expect(response).to have_gitlab_http_status(:ok)
            expect(response.body).to include('<error>foo</error>')
          end

          it_behaves_like 'gitlab_org_sitemap flag is disabled'
        end

        context 'when the sitemap was created suscessfully' do
          let(:result) { ServiceResponse.success(payload: { sitemap: 'foo' }) }

          it 'returns sitemap' do
            expect(response).to have_gitlab_http_status(:ok)
            expect(response.body).to eq('foo')
          end

          it_behaves_like 'gitlab_org_sitemap flag is disabled'
        end
      end
    end
  end
end
