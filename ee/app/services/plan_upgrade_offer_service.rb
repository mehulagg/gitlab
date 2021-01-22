# frozen_string_literal: true

class PlanUpgradeOfferService
  include Gitlab::Utils::StrongMemoize

  def initialize(namespace_id:)
    @namespace_id = namespace_id
  end

  def execute
    client.eligible_for_upgrade_offer(@namespace_id)
  end

  private

  def client
    Gitlab::SubscriptionPortal::Client
  end
end
