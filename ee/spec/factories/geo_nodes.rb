# frozen_string_literal: true

FactoryBot.define do
  factory :geo_node do
    sequence(:url) do |n|
      "http://node#{n}.example.com/gitlab"
    end

    sequence(:name) do |n|
      "node_name_#{n}"
    end

    primary { false }
    sync_object_storage { true }

    trait :primary do
      primary { true }
      minimum_reverification_interval { 7 }
      sync_object_storage { false }
    end

    trait :secondary do
      primary { false }
    end

    trait :local_storage_only do
      sync_object_storage { false }
    end

    trait :selective_sync_excludes_all_projects do
      selective_sync_type { 'shards' }
      selective_sync_shards { ['non-existent'] }
    end
  end

  factory :geo_node_with_selective_sync_for, parent: :geo_node do
    transient do
      model      { nil }
      namespaces { nil }
      shards     { nil }
    end

    after :build do |node, options|
      namespaces = options.namespaces
      shards = options.shards
      model = options.model

      if namespaces
        node.selective_sync_type = 'namespaces'
      elsif shards
        node.selective_sync_type = 'shards'
      end

      case namespaces
      when :model
        node.namespaces = [model]
      when :model_parent
        node.namespaces = [model.parent]
      when :model_parent_parent
        node.namespaces = [model.parent.parent]
      when :other
        node.namespaces = [create(:group)]
      end

      case shards
      when :model
        node.selective_sync_shards = [model.repository_storage]
      when :model_project
        project = create(:project, namespace: model)
        node.selective_sync_shards = [project.repository_storage]
      when :other
        node.selective_sync_shards = ['other_shard_name']
      end
    end
  end
end
