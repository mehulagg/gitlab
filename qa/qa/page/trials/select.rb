# frozen_string_literal: true

module QA
  module Page
    module Trials
      class Select < Chemlab::Page
        path '/-/trials/select'

        select :subscription_for, id: 'namespace_id'
        button :start_your_free_trial, value: 'Start your free trial'
      end
    end
  end
end
