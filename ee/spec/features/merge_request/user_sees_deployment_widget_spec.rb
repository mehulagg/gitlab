# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Merge request > User sees deployment widget', :js do
  describe 'when merge request has associated environments' do
    let(:user) { create(:user) }
    let(:project) { create(:project, :repository) }
    let(:merge_request) { create(:merge_request, :merged, source_project: project) }
    let(:environment) { create(:environment, project: project) }
    let(:role) { :developer }
    let(:ref) { merge_request.target_branch }
    let(:sha) { project.commit(ref).id }
    let(:pipeline) { create(:ci_pipeline, sha: sha, project: project, ref: ref) }
    let!(:manual) { }

    before do
      merge_request.update!(merge_commit_sha: sha)
      project.add_user(user, role)
      sign_in(user)
    end

    context 'when deployment succeeded' do
      let(:build) { create(:ci_build, :success, pipeline: pipeline) }
      let!(:deployment) { create(:deployment, :succeed, environment: environment, sha: sha, ref: ref, deployable: build) }

      context 'when the license flag is enabled' do
        before do
          stub_licensed_features(visual_review_app: true)
        end

        it 'displays the visual review button' do
          visit project_merge_request_path(project, merge_request)
          wait_for_requests

          expect(page).to have_selector('.js-review-button')
        end
      end

      context 'when the license flag is disabled' do
        before do
          stub_licensed_features(visual_review_app: false)
        end

        it 'does not display the button' do
          visit project_merge_request_path(project, merge_request)
          wait_for_requests

          expect(page).not_to have_selector('.js-review-button')
        end
      end
    end
  end
end
