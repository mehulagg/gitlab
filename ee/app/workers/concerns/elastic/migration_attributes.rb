# frozen_string_literal: true

module Elastic
  module MigrationAttributes
    extend ActiveSupport::Concern

    # This should be set if a migration should be run against data
    # in batches. This is typically the case if large amounts of documents
    # are being added/updated or if the documents are being moved
    # to a new index.
    def batched!
      options[:batched] = true
    end

    def batched?
      options[:batched]
    end

    protected

    def get_option(name)
      options[name] || superclass_options(name)
    end

    private

    def options
      @options ||= {}
    end

    def superclass_options(name)
      return unless superclass.include? MigrationAttributes

      superclass.get_option(name)
    end
  end
end
