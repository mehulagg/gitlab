# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_validation do
    dast_site_token

    validation_strategy { DastSiteValidation.validation_strategies[:text_file] }

    url_path { 'some/path/GitLab-DAST-Site-Validation.txt' }
  end
end
