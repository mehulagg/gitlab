# frozen_string_literal: true

class Disallow2FAWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include ExceptionBacktrace

  INTERVAL = 2.seconds.to_i

  feature_category :subgroups

  def perform(group_id)
    begin
      group = Group.find(group_id)
    rescue ActiveRecord::RecordNotFound
      return
    end
    subgroups = group.subgroups.where(require_two_factor_authentication: true)
    subgroups.update_all(require_two_factor_authentication: false)

    subgroups.find_each(batch_size: 100).with_index do |subgroup, index| # rubocop: disable CodeReuse/ActiveRecord
      delay = index * INTERVAL

      with_context(subgroup) do
        Update2FAForSubgroupsMembersWorker.perform_in(delay, subgroup.id)
      end
    end
  end
end
