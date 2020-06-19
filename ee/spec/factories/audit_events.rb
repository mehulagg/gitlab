# frozen_string_literal: true

FactoryBot.define do
  factory :audit_event, class: 'SecurityEvent', aliases: [:user_audit_event] do
    user

    transient { target_user { create(:user) } }

    entity_type { 'User' }
    entity_id   { target_user.id }
    ip_address { IPAddr.new '127.0.0.1' }
    details do
      {
        change: 'email address',
        from: 'admin@gitlab.com',
        to: 'maintainer@gitlab.com',
        author_name: user.name,
        target_id: target_user.id,
        target_type: 'User',
        target_details: target_user.name,
        ip_address: '127.0.0.1',
        entity_path: target_user.username
      }
    end

    trait :project_event do
      transient { target_project { create(:project) } }

      entity_type { 'Project' }
      entity_id   { target_project.id }
      ip_address { IPAddr.new '127.0.0.1' }
      details do
        {
          change: 'packges_enabled',
          from: true,
          to: false,
          author_name: user.name,
          target_id: target_project.id,
          target_type: 'Project',
          target_details: target_project.name,
          ip_address: '127.0.0.1',
          entity_path: 'gitlab.org/gitlab-ce'
        }
      end
    end

    trait :group_event do
      transient { target_group { create(:group) } }

      entity_type { 'Group' }
      entity_id   { target_group.id }
      ip_address { IPAddr.new '127.0.0.1' }
      details do
        {
          change: 'project_creation_level',
          from: nil,
          to: 'Developers + Maintainers',
          author_name: user.name,
          target_id: target_group.id,
          target_type: 'Group',
          target_details: target_group.name,
          ip_address: '127.0.0.1',
          entity_path: "gitlab-org"
        }
      end
    end

    factory :project_audit_event, traits: [:project_event]
    factory :group_audit_event, traits: [:group_event]
  end
end
