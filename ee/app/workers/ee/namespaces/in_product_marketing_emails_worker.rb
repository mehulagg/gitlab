# frozen_string_literal: true

module EE
  module Namespaces
    module InProductMarketingEmailsWorker # rubocop:disable Scalability/IdempotentWorker
      extend ::Gitlab::Utils::Override

      private

      override :paid_self_managed_instance?
      def paid_self_managed_instance?
        !::Gitlab.com? && License.current&.paid?
      end
    end
  end
end
