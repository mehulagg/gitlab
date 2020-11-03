# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    class UpdateExistingUsersThatRequireTwoFactorAuth
      class User < ActiveRecord::Base
        self.table_name = 'users'
      end

      def perform(start_id, stop_id)
        user_ids = User.where(id: start_id..stop_id).where(require_two_factor_authentication_from_group: true).select(:id)

        ActiveRecord::Base.connection.execute <<~SQL
          UPDATE users
            SET require_two_factor_authentication_from_group = FALSE
          WHERE users.id IN #{user_ids}
          AND users.require_two_factor_authentication_from_group = TRUE
          AND users.id NOT IN (
          SELECT users_groups_query.user_id FROM (SELECT users.id as user_id, members.source_id as group_ids FROM users
          LEFT JOIN members ON members.source_type = 'Namespace'
          AND members.requested_at IS NULL AND members.user_id = users.id
          AND members.type = 'GroupMember'
          WHERE users.require_two_factor_authentication_from_group = TRUE
          AND users.id IN #{user_ids}
          ) AS users_groups_query
          INNER JOIN LATERAL (
          WITH RECURSIVE "base_and_ancestors" AS ((SELECT "namespaces".* FROM "namespaces" WHERE "namespaces"."type" = 'Group' AND "namespaces"."id" = users_groups_query.group_ids)
          UNION
          (SELECT "namespaces".* FROM "namespaces", "base_and_ancestors" WHERE "namespaces"."type" = 'Group' AND "namespaces"."id" = "base_and_ancestors"."parent_id")), "base_and_descendants" AS ((SELECT "namespaces".* FROM "namespaces" WHERE "namespaces"."type" = 'Group' AND "namespaces"."id" = users_groups_query.group_ids)
          UNION
          (SELECT "namespaces".* FROM "namespaces", "base_and_descendants" WHERE "namespaces"."type" = 'Group' AND "namespaces"."parent_id" = "base_and_descendants"."id")) SELECT "namespaces".* FROM ((SELECT "namespaces".* FROM "base_and_ancestors" AS "namespaces" WHERE "namespaces"."type" = 'Group')
          UNION
          (SELECT "namespaces".* FROM "base_and_descendants" AS "namespaces" WHERE "namespaces"."type" = 'Group')) namespaces WHERE "namespaces"."type" = 'Group' and "namespaces".require_two_factor_authentication = true
          ) as hierarchy_tree ON TRUE);
        SQL
      end
    end
  end
end
