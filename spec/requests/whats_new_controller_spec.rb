# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WhatsNewController do
  describe 'whats_new_path' do
    context 'with whats_new_drawer feature enabled' do
      let(:dot_com) { false }
      let(:fixture_dir_glob) { Dir.glob(File.join('spec', 'fixtures', 'whats_new', '*.yml')) }

      before do
        stub_feature_flags(whats_new_drawer: true)
        allow(Gitlab).to receive(:com?).and_return(dot_com)
        allow(Dir).to receive(:glob).with(Rails.root.join('data', 'whats_new', '*.yml')).twice.and_return(fixture_dir_glob)
      end

      context 'with no page param' do
        it 'responds with paginated data and headers' do
          get whats_new_path, xhr: true

          expect(response.body).to eq([{ title: "bright and sunshinin' day", "self-managed": true, "gitlab-com": false }].to_json)
          expect(response.headers['X-Page']).to eq(1)
          expect(response.headers['X-Next-Page']).to eq(2)
        end

        context 'when Gitlab.com' do
          let(:dot_com) { true }

          it 'responds with a different set of data' do
            get whats_new_path, xhr: true

            expect(response.body).to eq([{ title: "I think I can make it now the pain is gone", "self-managed": false, "gitlab-com": true }].to_json)
          end
        end
      end

      context 'with page param' do
        it 'responds with paginated data and headers' do
          get whats_new_path(page: 2), xhr: true

          expect(response.body).to eq([{ title: 'bright', "self-managed": true, "gitlab-com": false }].to_json)
          expect(response.headers['X-Page']).to eq(2)
          expect(response.headers['X-Next-Page']).to eq(3)
        end

        context 'when there are no more paginated results' do
          it 'X-Next-Page is nil' do
            get whats_new_path(page: 3), xhr: true

            expect(response.body).to eq([{ title: "It's gonna be a bright", "self-managed": true, "gitlab-com": false }].to_json)
            expect(response.headers['X-Next-Page']).to be nil
          end
        end
      end
    end

    context 'with whats_new_drawer feature disabled' do
      before do
        stub_feature_flags(whats_new_drawer: false)
      end

      it 'returns a 404' do
        get whats_new_path, xhr: true

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
