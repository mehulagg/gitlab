# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Experiments do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, name: 'GitLab.com', path: 'gitlab-com') }

  let(:definition_yaml) { Rails.root.join('config', 'feature_flags', 'experiment', 'null_hypothesis.yml') }

  describe 'GET /experiments' do
    context 'when on .com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)

        definition = YAML.load_file(definition_yaml).deep_symbolize_keys!
        allow(Feature::Definition.definitions).to receive(:values).and_return([
          Feature::Definition.new(definition_yaml.to_s, definition),
          Feature::Definition.new(
            "foo/non_experiment.yml",
            definition.merge(type: 'development', name: 'non_experiment')
          )
        ])
      end

      it 'returns a 401 for anonymous users' do
        get api('/experiments')

        expect(response).to have_gitlab_http_status(:unauthorized)
      end

      it 'returns a 403 for users' do
        get api('/experiments', user)

        expect(response).to have_gitlab_http_status(:forbidden)
      end

      it 'returns a 403 for non human users' do
        bot = create(:user, :bot)
        group.add_developer(bot)

        get api('/experiments', bot)

        expect(response).to have_gitlab_http_status(:forbidden)
      end

      context 'for gitlab team members' do
        before do
          group.add_developer(user)
        end

        it 'returns the feature flag details' do
          get api('/experiments', user)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to include({
            key: "null_hypothesis",
            state: :off,
            enabled: false,
            name: "null_hypothesis",
            introduced_by_url: "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/45840",
            rollout_issue_url: nil,
            milestone: "13.7",
            type: "experiment",
            group: "group::adoption",
            default_enabled: false
          }.as_json)
        end

        it 'understands the state of the feature flag and what that means for an experiment' do
          Feature.enable_percentage_of_actors(:null_hypothesis, 1)

          get api('/experiments', user)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to include(hash_including({
            state: :conditional,
            enabled: true,
            name: "null_hypothesis"
          }.as_json))
        end
      end
    end

    context 'when not .com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)
      end

      it 'returns a 403 for users' do
        group.add_developer(user)

        get api('/experiments', user)

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
