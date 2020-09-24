# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    module UserMentions
      module Models
        class User < ApplicationRecord
          self.table_name = 'users'

          include FeatureGate

          def set_projects_limit
            10
          end
        end
      end
    end
  end
end
