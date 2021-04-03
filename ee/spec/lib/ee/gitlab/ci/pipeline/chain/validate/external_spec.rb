# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Chain::Validate::External do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:subscription) { create(:gitlab_subscription, :default, namespace: user.namespace) }
  let(:pipeline) { build(:ci_empty_pipeline, user: user, project: project) }

  let(:ci_yaml) do
    <<-CI_YAML
    job:
      script: ls
      parallel: 5
    CI_YAML
  end

  let(:yaml_processor_result) do
    ::Gitlab::Ci::YamlProcessor.new(
      ci_yaml, {
        project: project,
        sha: pipeline.sha,
        user: user
      }
    ).execute
  end

  let(:command) do
    Gitlab::Ci::Pipeline::Chain::Command.new(
      project: project, current_user: user, yaml_processor_result: yaml_processor_result, save_incompleted: true
    )
  end

  let(:step) { described_class.new(pipeline, command) }
  let(:validation_service_url) { 'https://validation-service.external/' }

  describe '#validation_service_payload' do
    before do
      stub_env('EXTERNAL_VALIDATION_SERVICE_URL', validation_service_url)
    end

    it 'respects the defined schema' do
      expect(::Gitlab::HTTP).to receive(:post) do |_url, params|
        expect(params[:body]).to match_schema('/external_validation', dir: 'ee')
      end

      step.perform!
    end

    it 'does not fire N+1 SQL queries' do
      stub_request(:post, validation_service_url)

      expect { step.perform! }.not_to exceed_query_limit(4)
    end
  end
end
