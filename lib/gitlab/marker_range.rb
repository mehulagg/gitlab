# frozen_string_literal: true

# It is a Range object extended with `mode` attribute
# MarkerRange not only keeps information about changed characters, but also
# the type of changes
module Gitlab
  class MarkerRange < Range
    DELETION = :deletion
    ADDITION = :addition

    def initialize(first, last, mode: nil)
      super(first, last)
      @mode = mode
    end

    attr_reader :mode
  end
end
