# frozen_string_literal: true

FactoryBot.define do
  factory :group_wiki, parent: :wiki do
    transient do
      group { association(:group) }
    end

    container { group }
  end
end
