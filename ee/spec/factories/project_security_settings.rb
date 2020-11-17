# frozen_string_literal: true

FactoryBot.define do
  factory :project_security_setting do
    project
    auto_fix_container_scanning { true }
    auto_fix_dast { true }
    auto_fix_dependency_scanning { true }
    auto_fix_sast { true }
  end
end
