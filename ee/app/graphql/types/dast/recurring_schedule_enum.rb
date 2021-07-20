# frozen_string_literal: true

module Types
  module Dast
    class RecurringScheduleEnum < BaseEnum
      graphql_name 'DastRecurringSchedule'
      description 'Recurring Schedules for Dast Profile Schedules'

      # https://gitlab.com/gitlab-org/gitlab/uploads/5b4ca48e20cd5dff0920a0183ac41836/4-choose-repeat.png
      value 'NEVER', value: 'never', description: 'Never repeat the dast scan'
      value 'DAILY', value: 'daily', description: 'Repeat the dast scan daily'
      value 'WEEKLY', value: 'weekly', description: 'Repeat the dast scan weekly'
      value 'MONTHLY', value: 'monthly', description: 'Repeat the dast scan monthly'
      value 'YEARLY', value: 'yearly', description: 'Repeat the dast scan yearly'
      value 'QUARTERLY', value: 'quarterly', description: 'Repeat the dast scan quarterly'
      value 'BIANNUALLY', value: 'biannually', description: 'Repeat the dast scan biannually'
    end
  end
end
