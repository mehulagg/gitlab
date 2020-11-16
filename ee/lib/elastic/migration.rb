# frozen_string_literal: true

module Elastic
  class Migration
    attr_reader :version

    def initialize(version)
      @version = version
    end

    def migrate
      raise NotImplementedError, 'Please extend Elastic::Migration'
    end

    def completed?
      raise NotImplementedError, 'Please extend Elastic::Migration'
    end

    private

    def helper
      @helper ||= Gitlab::Elastic::Helper.default
    end

    def client
      helper.client
    end

    def log(message)
      logger.info "[Elastic::Migration: #{self.version}] #{message}"
    end

    def logger
      @logger ||= ::Gitlab::Elasticsearch::Logger.build
    end
  end
end
