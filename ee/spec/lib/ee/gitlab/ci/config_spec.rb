# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config do
  let(:template_name) { 'test_template' }
  let(:template_repository) { create(:project, :custom_repo, files: { "gitlab-ci/#{template_name}.yml" => template_yml }) }

  let(:ci_yml) do
    <<-EOS
    sample_job:
      script:
        - echo 'test'
    EOS
  end

  let(:template_yml) do
    <<-EOS
    sample_job:
      script:
        - echo 'not test'
    EOS
  end

  subject { described_class.new(ci_yml) }

  before do
    stub_application_setting(file_template_project: template_repository, required_instance_ci_template: template_name)
    stub_licensed_features(custom_file_templates: true, required_ci_templates: true)
  end

  it 'processes the required includes' do
    expect(subject.to_hash[:sample_job][:script]).to eq(["echo 'not test'"])
  end
end
