# frozen_string_literal: true

module Elastic
  class DataMigrationService

    private

    def elastic_helper
      Gitlab::Elastic::Helper.default
    end
  end
end
