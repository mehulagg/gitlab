# frozen_string_literal: true

FactoryBot.define do
  factory :group_wiki, parent: :wiki do
    container { association(:group, :wiki_repo) }
  end
end
