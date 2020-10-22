# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module FixRubyObjectInAuditEvents
        extend ::Gitlab::Utils::Override

        override :perform
        def perform(start_id, stop_id)
          ActiveRecord::Base.connection.execute <<~SQL
            UPDATE
              audit_events
            SET
              details = regexp_replace(details, '!ruby/object.*name: ', '')
            WHERE id BETWEEN #{Integer(start_id)} AND #{Integer(stop_id)}
              AND details ~~ '%ruby/object%'
          SQL
        end
      end
    end
  end
end
