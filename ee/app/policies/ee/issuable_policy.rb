# frozen_string_literal: true

module EE
  module IssuablePolicy
    extend ActiveSupport::Concern

    prepended do
      rule { can?(:read_issue) }.policy do
        enable :read_issuable_metric_image
      end

      rule { can?(:create_issue) & can?(:update_issue) }.policy do
        enable :upload_issuable_metric_image
      end
    end
  end
end
