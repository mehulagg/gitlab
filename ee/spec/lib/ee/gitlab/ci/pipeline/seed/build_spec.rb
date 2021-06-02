# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Seed::Build do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:head_sha) { project.repository.head_commit.id }

  let(:pipeline) { build(:ci_empty_pipeline, project: project, sha: head_sha) }
  let(:seed_context) { double(pipeline: pipeline, root_variables: []) }
  let(:attributes) { { name: 'rspec', ref: 'master', scheduling_type: :stage, yaml_variables: yaml_variables } }

  let(:seed_build) { described_class.new(seed_context, attributes, []) }

  describe '#attributes' do
    subject { seed_build.attributes[:yaml_variables] }

    context 'dast' do
      let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

      let(:yaml_variables) do
        [{ key: 'DAST_SCANNER_PROFILE', value: dast_scanner_profile.name, public: true }]
      end

      context 'when the feature is not licensed' do
        it 'does not expand the variables' do
          expect(subject).to be_empty
        end
      end

      context 'when the feature is licensed' do
        before do
          stub_licensed_features(security_on_demand_scans: true)
        end

        context 'when the feature is not enabled' do
          before do
            stub_feature_flags(dast_configuration_ui: false)
          end

          it 'does not expand the variables' do
            expect(subject).to be_empty
          end
        end

        context 'when the feature is enabled' do
          before do
            stub_feature_flags(dast_configuration_ui: true)
          end

          context 'when the scanner profile does not exist' do
            let_it_be(:dast_scanner_profile) { build(:dast_scanner_profile, project: project) }

            it 'does not expand the variables' do
              expect(subject).to be_empty
            end
          end

          context 'when the scanner profile exists' do
            it 'expands the variables and adds them to the yaml_variables' do
              expect(subject).to eq(dast_scanner_profile.ci_variables.to_runner_variables)
            end
          end
        end
      end
    end
  end
end
