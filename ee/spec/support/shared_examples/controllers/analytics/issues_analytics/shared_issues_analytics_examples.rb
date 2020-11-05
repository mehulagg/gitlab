# frozen_string_literal: true

RSpec.shared_examples 'issue analytics controller' do
  describe 'GET #show' do
    subject { get :show, params: params }

    context 'when issue analytics is not available for license' do
      it 'renders 404' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user does not have permission to read the resource' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'renders 404' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when issue analytics is available for license' do
      before do
        stub_licensed_features(issues_analytics: true)
      end

      context 'as HTML' do
        before do
          params[:months_back] = 2
        end

        it 'renders show template' do
          subject

          expect(response).to render_template(:show)
        end
      end

      context 'as JSON' do
        subject { get :show, params: params, format: :json }

        context 'when new issue analytics data format is disabled' do
          before do
            stub_feature_flags(new_issues_analytics_chart_data: false)
          end

          it 'renders chart data as JSON' do
            expected_result = { issue1.created_at.strftime(IssuablesAnalytics::DATE_FORMAT) => 2 }

            subject

            expect(json_response).to include(expected_result)
          end
        end

        it 'renders new chart data as JSON' do
          month = issue1.created_at.strftime(Analytics::IssuesAnalytics::DATE_FORMAT)
          expected_result = {
            month => { 'created' => 2, 'closed' => 1, 'accumulated_open' => 1 }
          }

          subject

          expect(json_response).to include(expected_result)
        end

        context 'when user cannot view issues' do
          let(:guest) { create(:user) }

          before do
            group.add_guest(guest)
            sign_in(guest)
          end

          it 'does not count issues which user cannot view' do
            month = issue2.created_at.strftime(Analytics::IssuesAnalytics::DATE_FORMAT)
            expected_result = {
              month => { 'created' => 1, 'closed' => 1, 'accumulated_open' => 0 }
            }

            subject

            expect(json_response).to include(expected_result)
          end
        end
      end
    end
  end
end
