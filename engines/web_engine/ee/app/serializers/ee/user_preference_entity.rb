# frozen_string_literal: true

module EE
  module UserPreferenceEntity
    extend ActiveSupport::Concern

    prepended do
      expose :epic_notes_filter
    end
  end
end
