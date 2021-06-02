# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Seed::Build do
  let_it_be(:project) { create(:project, :repository) }

  let(:pipeline) { build(:ci_empty_pipeline, project: project) }
  let(:seed_context) { double(pipeline: pipeline, root_variables: []) }
  let(:stage) { 'dast' }
  let(:attributes) { { name: 'rspec', ref: 'master', scheduling_type: :stage, stage: stage, job_variables: job_variables } }

  let(:seed_build) { described_class.new(seed_context, attributes, []) }

  describe '#attributes' do
    subject { seed_build.attributes }

    context 'dast' do
      let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
      let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

      let(:dast_site_profile_name) { dast_site_profile.name }
      let(:dast_scanner_profile_name) { dast_scanner_profile.name }

      let(:job_variables) do
        [
          { key: 'DAST_SITE_PROFILE', value: dast_site_profile_name, public: true },
          { key: 'DAST_SCANNER_PROFILE', value: dast_scanner_profile_name, public: true }
        ]
      end

      shared_examples 'a permission error' do
        it 'does not expand the variables' do
          expect(subject[:yaml_variables]).to eq(job_variables)
        end
      end

      context 'when the feature is not licensed' do
        it_behaves_like 'a permission error'
      end

      context 'when the feature is licensed' do
        before do
          stub_licensed_features(security_on_demand_scans: true)
        end

        context 'when the feature is not enabled' do
          before do
            stub_feature_flags(dast_configuration_ui: false)
          end

          it_behaves_like 'a permission error'
        end

        context 'when the feature is enabled' do
          before do
            stub_feature_flags(dast_configuration_ui: true)
          end

          shared_examples 'variable expansion' do |key|
            let(:expected_variables) { Gitlab::Ci::Variables::Helpers.transform_to_yaml_variables(profile.ci_variables.to_hash) }

            context 'when the profile exists' do
              it 'expands the variables and adds them to the yaml_variables' do
                expect(subject[:yaml_variables]).to include(*expected_variables)
              end
            end

            context 'when the profile is not provided' do
              let(key) { nil }

              it 'does not expand the variables' do
                expect(subject[:yaml_variables]).not_to include(*expected_variables)
              end
            end

            context 'when the profile does not exist' do
              let(key) { SecureRandom.hex }

              it 'does not expand the variables' do
                expect(subject[:yaml_variables]).not_to include(*expected_variables)
              end
            end

            context 'when the stage is not dast' do
              let(:stage) { 'test' }

              it 'does not expand the variables' do
                expect(subject[:yaml_variables]).not_to include(*expected_variables)
              end
            end
          end

          context 'dast_site_profile' do
            let(:profile) { dast_site_profile }

            it_behaves_like 'variable expansion', :dast_site_profile_name
          end

          context 'dast_scanner_profile' do
            let(:profile) { dast_scanner_profile }

            it_behaves_like 'variable expansion', :dast_scanner_profile_name
          end
        end
      end
    end
  end
end
