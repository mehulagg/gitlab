# frozen_string_literal: true

module Issues
  class IssuesRelativePosition < ApplicationRecord
    belongs_to :issue, inverse_of: :relative_position
  end
end
