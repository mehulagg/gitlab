# frozen_string_literal: true
require 'spec_helper'

RSpec.describe API::MergeTrains do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:guest) { create(:user) }

  let(:user) { developer }

  before_all do
    project.add_developer(developer)
    project.add_guest(guest)
  end

  describe 'GET /projects/:id/merge_trains' do
    subject { get api("/projects/#{project.id}/merge_trains", user), params: params }

    let(:params) { {} }

    context 'when there are two merge trains' do
      let_it_be(:merge_train_1) { create(:merge_train, :merged, target_project: project) }
      let_it_be(:merge_train_2) { create(:merge_train, :idle, target_project: project) }

      it 'returns merge trains sorted by id in descending order' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('public_api/v4/merge_trains', dir: 'ee')
        expect(json_response.count).to eq(2)
        expect(json_response.first['id']).to eq(merge_train_2.id)
        expect(json_response.second['id']).to eq(merge_train_1.id)
      end

      it 'does not have N+1 problem' do
        control_count = ActiveRecord::QueryRecorder.new { subject }

        create_list(:merge_train, 3, target_project: project)

        expect { get api("/projects/#{project.id}/merge_trains", user) }
          .not_to exceed_query_limit(control_count)
      end

      context 'when sort is specified' do
        let(:params) { { sort: 'asc' } }

        it 'returns merge trains sorted by id in ascending order' do
          subject

          expect(json_response.first['id']).to eq(merge_train_1.id)
          expect(json_response.second['id']).to eq(merge_train_2.id)
        end
      end

      context 'when scope is specified' do
        context 'when scope is active' do
          let(:params) { { scope: 'active' } }

          it 'returns active merge trains' do
            subject

            expect(json_response.count).to eq(1)
            expect(json_response.first['id']).to eq(merge_train_2.id)
          end
        end

        context 'when scope is complete' do
          let(:params) { { scope: 'complete' } }

          it 'returns complete merge trains' do
            subject

            expect(json_response.count).to eq(1)
            expect(json_response.first['id']).to eq(merge_train_1.id)
          end
        end
      end

      context 'when user is guest' do
        let(:user) { guest }

        it 'forbids the request' do
          subject

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end
  end
end
