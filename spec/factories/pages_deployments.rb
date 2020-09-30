# frozen_string_literal: true

FactoryBot.define do
  factory :pages_deployment, class: 'PagesDeployment' do
    project

    after(:build) do |deployment, _evaluator|
      deployment.file = fixture_file_upload(
        Rails.root.join("spec/fixtures/pages.zip")
      )
      deployment.size = deployment.file.size
    end
  end
end
