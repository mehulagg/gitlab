# frozen_string_literal: true

module Namespaces
  class InProductMarketingEmailsWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    feature_category :subgroups
    urgency :low

    def perform
      return unless enabled_on_dotcom? || enabled_on_self_managed?

      Namespaces::InProductMarketingEmailsService.send_for_all_tracks_and_intervals
    end

    private

    def enabled_on_dotcom?
      Gitlab.com? && Gitlab::Experimentation.active?(:in_product_marketing_emails)
    end

    # Enable on 50% of self managed instances where usage ping is enabled
    def enabled_on_self_managed?
      return if Gitlab.com?
      return unless Gitlab::CurrentSettings.usage_ping_enabled?
      return if User.single_user&.requires_usage_stats_consent?

      uuid = Gitlab::CurrentSettings.uuid
      Zlib.crc32(uuid).even?
    end
  end
end
