# frozen_string_literal: true

class DestroyPagesDeploymentsWorker
  include ApplicationWorker

  idempotent!

  feature_category :pages

  def perform(deployment_ids)
    # we need to use destroy_all to remove associated files from storage
    PagesDeployment.where(id: deployment_ids).destroy_all # rubocop: disable Cop/DestroyAll, CodeReuse/ActiveRecord
  end
end
