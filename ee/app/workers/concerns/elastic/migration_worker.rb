# frozen_string_literal: true

module Elastic
  module MigrationWorker
    extend ActiveSupport::Concern

    def perform(*args)
      raise 'TIMESTAMP is required for a MigrationWorker' unless self.class.const_defined? :TIMESTAMP

      super
    end
  end
end
