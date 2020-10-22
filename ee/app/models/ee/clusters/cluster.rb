# frozen_string_literal: true

module EE
  module Clusters
    module Cluster
      extend ActiveSupport::Concern

      prepended do
        include UsageStatistics
      end
    end
  end
end
