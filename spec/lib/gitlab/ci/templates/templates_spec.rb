# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CI YML Templates' do
  subject { Gitlab::Ci::YamlProcessor.new(content).execute }

  let(:all_templates) { Gitlab::Template::GitlabCiYmlTemplate.all.map(&:full_name) }
  let(:excluded_templates) do
    excluded = all_templates.select do |name|
      Gitlab::Template::GitlabCiYmlTemplate.excluded_patterns.any? { |pattern| pattern.match?(name) }
    end
    excluded + ["Terraform.gitlab-ci.yml"]
  end

  before do
    stub_feature_flags(
      redirect_to_latest_template_terraform: false,
      redirect_to_latest_template_security_api_fuzzing: false,
      redirect_to_latest_template_security_dast: false)
  end

  shared_examples 'require default stages to be included' do
    it 'require default stages to be included' do
      expect(subject.stages).to include(*Gitlab::Ci::Config::Entry::Stages.default)
    end
  end

  context 'that support autodevops' do
    exceptions = [
      'Security/DAST.gitlab-ci.yml',        # DAST stage is defined inside AutoDevops yml
      'Security/DAST-API.gitlab-ci.yml',    # no auto-devops
      'Security/API-Fuzzing.gitlab-ci.yml'  # no auto-devops
    ]

    context 'when including available templates in a CI YAML configuration' do
      using RSpec::Parameterized::TableSyntax

      where(:template_name) do
        all_templates - excluded_templates - exceptions
      end

      with_them do
        let(:content) do
          <<~EOS
            include:
              - template: #{template_name}

            concrete_build_implemented_by_a_user:
              stage: test
              script: do something
          EOS
        end

        it { is_expected.to be_valid }

        include_examples 'require default stages to be included'
      end
    end

    context 'when including unavailable templates in a CI YAML configuration' do
      using RSpec::Parameterized::TableSyntax

      where(:template_name) do
        excluded_templates
      end

      with_them do
        let(:content) do
          <<~EOS
            include:
              - template: #{template_name}

            concrete_build_implemented_by_a_user:
              stage: test
              script: do something
          EOS
        end

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe 'that do not support autodevops' do
    context 'when DAST API template' do
      # The DAST API template purposly excludes a stages
      # definition.

      let(:template_name) { 'Security/DAST-API.gitlab-ci.yml' }

      context 'with default stages' do
        let(:content) do
          <<~EOS
            include:
              - template: #{template_name}

            concrete_build_implemented_by_a_user:
              stage: test
              script: do something
          EOS
        end

        it { is_expected.not_to be_valid }
      end

      context 'with defined stages' do
        let(:content) do
          <<~EOS
            include:
              - template: #{template_name}

            stages:
              - build
              - test
              - deploy
              - dast

            concrete_build_implemented_by_a_user:
              stage: test
              script: do something
          EOS
        end

        it { is_expected.to be_valid }

        include_examples 'require default stages to be included'
      end
    end

    context 'when API Fuzzing template' do
      # The API Fuzzing template purposly excludes a stages
      # definition.

      let(:template_name) { 'Security/API-Fuzzing.gitlab-ci.yml' }

      context 'with default stages' do
        let(:content) do
          <<~EOS
            include:
              - template: #{template_name}

            concrete_build_implemented_by_a_user:
              stage: test
              script: do something
          EOS
        end

        it { is_expected.not_to be_valid }
      end

      context 'with defined stages' do
        let(:content) do
          <<~EOS
            include:
              - template: #{template_name}

            stages:
              - build
              - test
              - deploy
              - fuzz

            concrete_build_implemented_by_a_user:
              stage: test
              script: do something
          EOS
        end

        it { is_expected.to be_valid }

        include_examples 'require default stages to be included'
      end
    end
  end

  describe 'Template metadata is correctly defined' do
    using RSpec::Parameterized::TableSyntax

    where(:template_name) do
      Gitlab::Template::GitlabCiYmlTemplate.all.map(&:name)
    end

    with_them do
      let(:content) do
        Gitlab::Template::GitlabCiYmlTemplate.find(template_name).content
      end

      let(:config) do
        Gitlab::Ci::Config::Yaml.load!(content)
      end

      it 'has template metadata' do
        expect(config[:template_metadata]).to be_present,
          "The CI/CD template metadata must be defined in the template \"#{template_name}\", however, it doesn't exist currently. \n" \
          "Please add it in the template file. If you're new to this process, \n" \
          "see https://docs.gitlab.com/ee/development/cicd/templates.html#template-metadata for the instruction."
      end

      it "has correct GitLab groups in 'maintainers' attribute" do
        expect(config[:template_metadata][:maintainers]).to be_present
        expect(config[:template_metadata][:maintainers]).to all(be_start_with('group::'))
      end

      it "has correct GitLab DevOps stage as 'stages' attribute" do
        expect(config[:template_metadata][:stages]).to be_present
        expect(config[:template_metadata][:stages]).to all(be_start_with('devops::'))
      end

      it "has correct GitLab Feature Category as 'categories' attribute" do
        expect(config[:template_metadata][:categories]).to be_present
        expect(config[:template_metadata][:categories]).to all(be_start_with('Category:'))
      end
    end
  end
end
