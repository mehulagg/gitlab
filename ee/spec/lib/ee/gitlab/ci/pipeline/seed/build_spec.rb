# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Seed::Build do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user, developer_projects: [project]) }

  let(:pipeline) { build(:ci_empty_pipeline, project: project, user: user) }
  let(:seed_context) { double(pipeline: pipeline, root_variables: []) }
  let(:stage) { 'dast' }
  let(:attributes) { { name: 'rspec', ref: project.default_branch, scheduling_type: :stage, stage: stage, options: { dast_configuration: dast_configuration } } }

  let(:seed_build) { described_class.new(seed_context, attributes, []) }

  describe '#attributes' do
    subject { seed_build.attributes }

    context 'dast' do
      let_it_be(:dast_site_profile) { create(:dast_site_profile, project: project) }
      let_it_be(:dast_scanner_profile) { create(:dast_scanner_profile, project: project) }

      let(:dast_site_profile_name) { dast_site_profile.name }
      let(:dast_scanner_profile_name) { dast_scanner_profile.name }

      let(:dast_configuration) { { site_profile: dast_site_profile_name, scanner_profile: dast_scanner_profile_name } }

      shared_examples 'it does not change build attributes' do
        it 'does not add dast_site_profile or dast_scanner_profile' do
          expect(subject.keys).not_to include(:dast_site_profile, :dast_scanner_profile)
        end
      end

      context 'when the feature is not licensed' do
        it_behaves_like 'it does not change build attributes'
      end

      context 'when the feature is licensed' do
        before do
          stub_licensed_features(security_on_demand_scans: true)
        end

        context 'when the feature is not enabled' do
          before do
            stub_feature_flags(dast_configuration_ui: false)
          end

          it_behaves_like 'it does not change build attributes'
        end

        context 'when the feature is enabled' do
          before do
            stub_feature_flags(dast_configuration_ui: true)
          end

          shared_examples 'it looks up dast profiles in the database' do |key|
            context 'when the profile exists' do
              it 'adds the profile to the build attributes' do
                expect(subject).to include(profile.class.underscore.to_sym => profile)
              end
            end

            shared_examples 'it has no effect' do
              it 'does not add the profile to the build attributes' do
                expect(subject).not_to include(profile.class.underscore.to_sym => profile)
              end
            end

            context 'when the profile is not provided' do
              let(key) { nil }

              it_behaves_like 'it has no effect'
            end

            context 'when the profile does not exist' do
              let(key) { SecureRandom.hex }

              it_behaves_like 'it has no effect'
            end

            context 'when the stage is not dast' do
              let(:stage) { 'test' }

              it_behaves_like 'it has no effect'
            end
          end

          context 'dast_site_profile' do
            let(:profile) { dast_site_profile }

            it_behaves_like 'it looks up dast profiles in the database', :dast_site_profile_name
          end

          context 'dast_scanner_profile' do
            let(:profile) { dast_scanner_profile }

            it_behaves_like 'it looks up dast profiles in the database', :dast_scanner_profile_name
          end
        end
      end
    end
  end
end
