# frozen_string_literal: true

FactoryBot.define do
  factory :group_repository_storage_move, class: 'GroupRepositoryStorageMove' do
    container { association(:group) }

    source_storage_name { 'default' }

    trait :scheduled do
      state { GroupRepositoryStorageMove.state_machines[:state].states[:scheduled].value }
    end

    trait :started do
      state { GroupRepositoryStorageMove.state_machines[:state].states[:started].value }
    end

    trait :replicated do
      state { GroupRepositoryStorageMove.state_machines[:state].states[:replicated].value }
    end

    trait :finished do
      state { GroupRepositoryStorageMove.state_machines[:state].states[:finished].value }
    end

    trait :failed do
      state { GroupRepositoryStorageMove.state_machines[:state].states[:failed].value }
    end
  end
end
