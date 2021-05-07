# frozen_string_literal: true

module EE
  module Ci
    module PipelineEntity
      extend ActiveSupport::Concern

      prepended do
        expose :flags do
          expose :merge_train_pipeline?, as: :merge_train_pipeline
        end
      end
    end
  end
end
