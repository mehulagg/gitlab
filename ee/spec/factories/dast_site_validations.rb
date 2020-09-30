# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_validation do
    validation_strategy { DastSiteValidation.validation_strategies[:text_file] }
    url_path { 'some/path/GitLab-DAST-Site-Validation.txt' }

    before(:create) do |dast_site_validation|
      dast_site_validation.dast_site_token ||= FactoryBot.create(:dast_site_token)
    end
  end
end
