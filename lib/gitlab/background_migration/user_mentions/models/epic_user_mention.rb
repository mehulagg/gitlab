# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    module UserMentions
      module Models
        class EpicUserMention < ActiveRecord::Base
          self.table_name = 'epic_user_mentions'
          self.inheritance_column = :_type_disabled

          def self.resource_foreign_key
            :epic_id
          end
        end
      end
    end
  end
end
