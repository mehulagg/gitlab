# frozen_string_literal: true

require 'fast_spec_helper'

# This spec makes sure that CI/CD tempaltes are correctly defined
# based on https://docs.gitlab.com/ee/development/cicd/templates.html.
RSpec.describe 'CI/CD template metadata' do
  Gitlab::Template::GitlabCiYmlTemplate.all(ignore_category: true).each do |template|
    it "#{template.name} has metadata" do
      expect(template.metadata).to be_exist,
        "CI/CD templates must have metadata. Please follow https://docs.gitlab.com/ee/development/cicd/templates.html#template-metadata to add new metadata"
    end

    it "#{template.name} has valid metadata format" do
      expect(template.metadata.valid?).to eq(true),
        "The tempalte metadata has the validation error: #{template.metadata.validation_errors}"
    end

    if template.metadata.exist? && template.metadata.ignore_guideline_violation != true
      if template.metadata.type == 'pipeline'
        describe "#{template.name} as pipeline template" do
          context "with 'include' keyword" do
            it 'includes only job templates' do
              template.parsed_content['include']&.each do |inclusion|
                included_template_name = inclusion['template'].gsub('.gitlab-ci.yml', '')
                included_template = Gitlab::Template::GitlabCiYmlTemplate.find(included_template_name)
                expect(included_template.metadata.type).to eq('job'),
                  "#{template.name} can not include #{included_template.name} because both pipeline templates"
              end
            end
          end
        end
      elsif template.metadata.type == 'job'
        describe "#{template.name} as job template" do
          let(:global_keywords) { %w[default variables stages image workflow include services] }

          it 'does not include global keywords' do
            global_keywords.each do |global_keyword|
              expect(template.parsed_content).not_to include(global_keyword)
            end
          end
        end
      end
    end
  end
end
