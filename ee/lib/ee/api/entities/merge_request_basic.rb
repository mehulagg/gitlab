# frozen_string_literal: true

module EE
  module API
    module Entities
      module MergeRequestBasic
        extend ActiveSupport::Concern

        prepended do
          expose :approvals_before_merge
        end
      end
    end
  end
end
