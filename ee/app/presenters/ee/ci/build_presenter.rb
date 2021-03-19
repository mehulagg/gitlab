# frozen_string_literal: true

module EE
  module Ci
    module BuildPresenter
      extend ActiveSupport::Concern

      def retryable?
        !merge_train_pipeline? && super
      end
    end
  end
end
