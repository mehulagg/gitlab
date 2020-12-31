# frozen_string_literal: true

module Namespaces
  class InProductMarketingEmailsWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    feature_category :subgroups
    urgency :low

    def perform
      return unless Gitlab::Experimentation.active?(:in_product_marketing_emails)

      Namespaces::InProductMarketingEmailsService::TRACKS.each do |track|
        Namespaces::InProductMarketingEmailsService::INTERVALS.each do |interval|
          Namespaces::InProductMarketingEmailsService.new(track, interval).execute
        end
      end
    end
  end
end
