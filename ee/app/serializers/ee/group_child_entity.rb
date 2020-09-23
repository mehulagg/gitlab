# frozen_string_literal: true

module EE
  module GroupChildEntity
    extend ActiveSupport::Concern

    prepended do
      # For both group and project
      expose :marked_for_deletion do |instance|
        instance.marked_for_deletion?
      end
    end
  end
end
