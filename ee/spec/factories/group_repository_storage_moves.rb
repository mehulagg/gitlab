# frozen_string_literal: true

FactoryBot.define do
  factory :group_repository_storage_move, class: 'Groups::RepositoryStorageMove' do
    container { association(:group) }

    source_storage_name { 'default' }

    trait :scheduled do
      state { Groups::RepositoryStorageMove.state_machines[:state].states[:scheduled].value }
    end

    trait :started do
      state { Groups::RepositoryStorageMove.state_machines[:state].states[:started].value }
    end

    trait :replicated do
      state { Groups::RepositoryStorageMove.state_machines[:state].states[:replicated].value }
    end

    trait :finished do
      state { Groups::RepositoryStorageMove.state_machines[:state].states[:finished].value }
    end

    trait :failed do
      state { Groups::RepositoryStorageMove.state_machines[:state].states[:failed].value }
    end
  end
end
