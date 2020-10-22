# frozen_string_literal: true

module EE
  module Banzai
    module ReferenceParser
      module IterationParser
        private

        def can_read_reference?(user, ref_project, node)
          can?(user, :read_iteration, ref_project)
        end
      end
    end
  end
end
