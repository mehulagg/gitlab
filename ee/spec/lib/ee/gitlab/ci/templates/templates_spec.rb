# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "CI YML Templates" do
  using RSpec::Parameterized::TableSyntax

  subject { Gitlab::Ci::YamlProcessor.new(content).execute }

  where(:template_name) do
    Gitlab::Template::GitlabCiYmlTemplate.all.map(&:full_name)
  end

  before do
    stub_feature_flags(
      redirect_to_latest_template_terraform: false,
      redirect_to_latest_template_security_dast: false,
      redirect_to_latest_template_security_api_fuzzing: false,
      redirect_to_latest_template_jobs_browser_performance_testing: false)
  end

  with_them do
    let(:content) do
      if template_name == 'Security/DAST-API.gitlab-ci.yml'
        # The DAST-API template purposly excludes a stages
        # definition.

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
      else
        <<~EOS
          include:
            - template: #{template_name}

          concrete_build_implemented_by_a_user:
            stage: test
            script: do something
        EOS
      end
    end

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'require default stages to be included' do
      expect(subject.stages).to include(*Gitlab::Ci::Config::Entry::Stages.default)
    end
  end
end
