# frozen_string_literal: true

class DisableExpirationPoliciesLinkedToNoContainerImages < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  BATCH_SIZE = 1000

  class ContainerExpirationPolicy < ActiveRecord::Base
    include ::EachBatch

    self.table_name = 'container_expiration_policies'
  end

  class ContainerRepository < ActiveRecord::Base
    self.table_name = 'container_repositories'
  end

  def up
    policies = ContainerExpirationPolicy
      .where(enabled: true)
      .where.not(
        'EXISTS (?)',
        ContainerRepository.select(1)
                           .where(
                             'container_repositories.project_id = container_expiration_policies.project_id'
                           )
      )

    policies.each_batch(of: BATCH_SIZE) do |batch, _|
      batch.update_all(enabled: false)
    end
  end

  def down
    # this migration is irreversible
  end
end
