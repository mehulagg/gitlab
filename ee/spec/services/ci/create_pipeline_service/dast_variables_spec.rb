# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::CreatePipelineService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user, developer_projects: [project]) }
  let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
  let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

  let(:ci_variables) do
    dast_site_profile.ci_variables
      .concat(dast_scanner_profile.ci_variables)
      .to_runner_variables
  end

  let(:secret_ci_variables) do
    dast_site_profile.secret_ci_variables(user)
      .to_runner_variables
  end

  let(:config) do
    <<~EOY
    stages:
      - dast
      - test
    dast:
      stage: dast
      dast_profiles:
        site: #{dast_site_profile.name}
        scanner: #{dast_scanner_profile.name}
      script:
        - env
    test:
      stage: test
      variables:
        DAST_SITE_PROFILE: #{dast_site_profile.name}
        DAST_SCANNER_PROFILE: #{dast_scanner_profile.name}
      script:
        - env
    EOY
  end

  let(:dast_variables) do
    subject.builds
      .find_by(name: 'dast')
      .variables
      .to_runner_variables
  end

  let(:test_variables) do
    subject.builds
      .find_by(name: 'test')
      .variables
      .to_runner_variables
  end

  subject { described_class.new(project, user, ref: 'refs/heads/master').execute(:push) }

  before do
    stub_ci_pipeline_yaml_file(config)
  end

  shared_examples 'it does not expand the dast variables' do
    it 'does not include the profile variables' do
      expect(test_variables).not_to include(*ci_variables)
    end
  end

  context 'when the feature is not licensed' do
    it_behaves_like 'it does not expand the dast variables'
  end

  context 'when the feature is licensed' do
    before do
      stub_licensed_features(security_on_demand_scans: true)
    end

    context 'when the feature is not enabled' do
      before do
        stub_feature_flags(dast_configuration_ui: false)
      end

      it_behaves_like 'it does not expand the dast variables'
    end

    context 'when the feature is enabled' do
      before do
        stub_feature_flags(dast_configuration_ui: true)
      end

      context 'when the stage is dast' do
        it 'expands the dast variables' do
          expect(dast_variables).to include(*ci_variables)
        end

        context 'when the user has permission' do
          it 'expands the secret dast variables' do
            expect(dast_variables).to include(*secret_ci_variables)
          end
        end

        context 'when the user does not have permission' do
          let_it_be(:user) { create(:user) }

          it 'is not possible to create a pipeline' do
            expect(subject).not_to be_persisted
          end
        end
      end

      context 'when the stage is not dast' do
        it_behaves_like 'it does not expand the dast variables'
      end
    end
  end
end
