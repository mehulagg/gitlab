# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe 'CI/CD template metadata' do
  Gitlab::Template::GitlabCiYmlTemplate.all.each do |template|
    it "#{template.full_name} has metadata" do
      ci_yaml = YAML.load(template.content)
      expect(ci_yaml['.cicd-template-metadata']).to be_present
    end
  end
end
