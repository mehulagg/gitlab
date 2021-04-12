# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::CiConfiguration::SecretDetectionBuildActions do
  let(:params) { {} }

  context 'with existing .gitlab-ci.yml' do
    let(:auto_devops_enabled) { false }

    context 'sast has not been included' do
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#priority-of-environment-variables
          stages:
          - test
          - security
          variables:
            RANDOM: make sure this persists
          include:
          - template: existing.yml
          - template: Security/Secret-Detection.gitlab-ci.yml
        CI_YML
      end

      context 'template includes are an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test security),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => [{ "template" => "existing.yml" }] }
        end

        subject(:result) { described_class.new(auto_devops_enabled, params, gitlab_ci_content).generate }

        it 'generates the correct YML' do
          expect(result.first[:action]).to eq('update')
          expect(result.first[:content]).to eq(expected_yml)
        end
      end

      context 'template include is not an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test security),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => { "template" => "existing.yml" } }
        end

        subject(:result) { described_class.new(auto_devops_enabled, params, gitlab_ci_content).generate }

        it 'generates the correct YML' do
          expect(result.first[:action]).to eq('update')
          expect(result.first[:content]).to eq(expected_yml)
        end
      end
    end

    context 'sast has been included' do
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#priority-of-environment-variables
          stages:
          - test
          variables:
            RANDOM: make sure this persists
          include:
          - template: Security/Secret-Detection.gitlab-ci.yml
        CI_YML
      end

      context 'sast template include are an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => [{ "template" => "Security/Secret-Detection.gitlab-ci.yml" }] }
        end

        subject(:result) { described_class.new(auto_devops_enabled, params, gitlab_ci_content).generate }

        it 'generates the correct YML' do
          expect(result.first[:action]).to eq('update')
          expect(result.first[:content]).to eq(expected_yml)
        end
      end

      context 'sast template include is not an array' do
        let(:gitlab_ci_content) do
          { "stages" => %w(test),
            "variables" => { "RANDOM" => "make sure this persists" },
            "include" => { "template" => "Security/Secret-Detection.gitlab-ci.yml" } }
        end

        subject(:result) { described_class.new(auto_devops_enabled, params, gitlab_ci_content).generate }

        it 'generates the correct YML' do
          expect(result.first[:action]).to eq('update')
          expect(result.first[:content]).to eq(expected_yml)
        end
      end
    end

    def existing_gitlab_ci_and_single_template_with_sast_and_default_stage
      { "stages" => %w(test),
       "variables" => { "SECURE_ANALYZERS_PREFIX" => "localhost:5000/analyzers" },
       "sast" => { "variables" => { "SAST_ANALYZER_IMAGE_TAG" => 2, "SEARCH_MAX_DEPTH" => 1 }, "stage" => "test" },
       "include" => { "template" => "Security/SAST.gitlab-ci.yml" } }
    end

    def existing_gitlab_ci_with_no_variables
      { "stages" => %w(test security),
       "sast" => { "variables" => { "SAST_ANALYZER_IMAGE_TAG" => 2, "SEARCH_MAX_DEPTH" => 1 }, "stage" => "security" },
       "include" => [{ "template" => "Security/SAST.gitlab-ci.yml" }] }
    end

    def existing_gitlab_ci
      { "stages" => %w(test security),
       "variables" => { "RANDOM" => "make sure this persists", "SECURE_ANALYZERS_PREFIX" => "bad_prefix" },
       "sast" => { "variables" => { "SAST_ANALYZER_IMAGE_TAG" => 2, "SEARCH_MAX_DEPTH" => 1 }, "stage" => "security" },
       "include" => [{ "template" => "Security/SAST.gitlab-ci.yml" }] }
    end
  end

  context 'with no .gitlab-ci.yml' do
    let(:gitlab_ci_content) { nil }

    context 'autodevops disabled' do
      let(:auto_devops_enabled) { false }
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#priority-of-environment-variables
          include:
          - template: Security/Secret-Detection.gitlab-ci.yml
        CI_YML
      end

      subject(:result) { described_class.new(auto_devops_enabled, params, gitlab_ci_content).generate }

      it 'generates the correct YML' do
        expect(result.first[:action]).to eq('create')
        expect(result.first[:content]).to eq(expected_yml)
      end
    end

    context 'with autodevops enabled' do
      let(:auto_devops_enabled) { true }
      let(:expected_yml) do
        <<-CI_YML.strip_heredoc
          # You can override the included template(s) by including variable overrides
          # SAST customization: https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings
          # Secret Detection customization: https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings
          # Note that environment variables can be set in several places
          # See https://docs.gitlab.com/ee/ci/variables/#priority-of-environment-variables
          include:
          - template: Auto-DevOps.gitlab-ci.yml
        CI_YML
      end

      subject(:result) { described_class.new(auto_devops_enabled, params, gitlab_ci_content).generate }

      before do
        allow_next_instance_of(described_class) do |sast_build_actions|
          allow(sast_build_actions).to receive(:auto_devops_stages).and_return(fast_auto_devops_stages)
        end
      end

      it 'generates the correct YML' do
        expect(result.first[:action]).to eq('create')
        expect(result.first[:content]).to eq(expected_yml)
      end
    end
  end

  # stubbing this method allows this spec file to use fast_spec_helper
  def fast_auto_devops_stages
    auto_devops_template = YAML.safe_load( File.read('lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml') )
    auto_devops_template['stages']
  end
end
