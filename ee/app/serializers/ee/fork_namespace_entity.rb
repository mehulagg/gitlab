# frozen_string_literal: true

module EE
  module ForkNamespaceEntity
    extend ActiveSupport::Concern

    prepended do
      expose :marked_for_deletion do |namespace|
        namespace.marked_for_deletion?
      end
    end
  end
end
