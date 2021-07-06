# frozen_string_literal: true

require_relative '../support/helpers/test_env'

FactoryBot.define do
  factory :project_namespace, class: 'ProjectNamespace' do
    sequence(:name) { |n| "project#{n}" }
    path { "#{name.downcase.gsub(/\s/, '_')}-namespace" }
    project
  end
end
