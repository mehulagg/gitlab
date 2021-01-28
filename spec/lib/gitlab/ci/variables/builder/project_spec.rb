# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Variables::Builder::Project do
  describe '#predefined_project_variables' do
    let_it_be(:project) { create(:project, :repository) }

    subject { described_class.new(project).fabricate.to_runner_variables }

    specify do
      expect(subject).to include({ key: 'CI_PROJECT_CONFIG_PATH', value: Ci::Pipeline::DEFAULT_CONFIG_PATH, public: true, masked: false })
    end

    context 'when ci config path is overridden' do
      before do
        project.update!(ci_config_path: 'random.yml')
      end

      it { expect(subject).to include({ key: 'CI_PROJECT_CONFIG_PATH', value: 'random.yml', public: true, masked: false }) }
    end
  end

  describe '#api_variables' do
    let_it_be(:project) { create(:project) }

    subject(:api_variables) { described_class.new(project).fabricate.to_runner_variables }

    it 'exposes API v4 URL' do
      api_v4_url_variable = api_variables.find { |variable| variable[:key] == 'CI_API_V4_URL' }
      expect(api_v4_url_variable[:value]).to match(/http.*\/api\/v4/)
    end

    it 'contains a URL variable for every supported API version' do
      # Ensure future API versions have proper variables defined. We're not doing this for v3.
      supported_versions = API::API.versions - ['v3']
      supported_versions = supported_versions.select do |version|
        API::API.routes.select { |route| route.version == version }.many?
      end

      required_variables = supported_versions.map do |version|
        "CI_API_#{version.upcase}_URL"
      end

      expect(api_variables.map { |variable| variable[:key] }).to include(*required_variables)
    end
  end
end
