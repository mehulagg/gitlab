# frozen_string_literal: true

module Boards
  class EpicList < ApplicationRecord
    include ::Boards::Listable

    belongs_to :epic_board, optional: false, inverse_of: :epic_lists
    belongs_to :label, inverse_of: :epic_lists
    has_many :epic_list_user_preferences, inverse_of: :epic_list

    validates :label_id, uniqueness: { scope: :epic_board_id }, if: :label?

    enum list_type: { backlog: 0, label: 1, closed: 2 }

    scope :preload_associated_models, -> { preload(:epic_board, label: :priorities) }
    scope :movable, -> { where(list_type: list_types.slice(*movable_types).values) }

    alias_method :preferences, :epic_list_user_preferences
    alias_method :board, :epic_board

    def preferences_for(user)
      return preferences.build unless user

      BatchLoader.for(epic_list_id: id, user_id: user.id).batch(default_value: preferences.build(user: user)) do |items, loader|
        list_ids = items.map { |i| i[:epic_list_id] }
        user_ids = items.map { |i| i[:user_id] }

        ::Boards::EpicListUserPreference.where(epic_list_id: list_ids.uniq, user_id: user_ids.uniq).find_each do |preference|
          loader.call({ epic_list_id: preference.epic_list_id, user_id: preference.user_id }, preference)
        end
      end
    end
  end
end
