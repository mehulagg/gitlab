# frozen_string_literal: true

module Gitlab
  module StaticSiteEditor
    module Config
      #
      # Base GitLab Static Site Editor Configuration facade
      #
      class FileConfig
        ConfigError = Class.new(StandardError)

        def initialize(yaml)
          content_hash = content_hash(yaml)
          @global = Entry::Global.new(content_hash)
          @global.compose!
        rescue Gitlab::Config::Loader::FormatError => e
          raise FileConfig::ConfigError, e.message
        end

        def valid?
          @global.valid?
        end

        def errors
          @global.errors
        end

        def to_hash
          # NOTE 1: This doesn't just return the original content hash from yaml like other config files.
          #         Instead, it composes all the values (including any defaults for missing entries) into
          #         a single hash so it can be easily passed to the frontend app as a JSON payload object.
          #
          # NOTE 2: The current approach of simply mapping all the descendents' keys and values ('config')
          #         into a flat hash may not work as we add more complex, non-scalar entries.
          @global.descendants.map { |descendant| [descendant.key, descendant.config] }.to_h
        end

        private

        def content_hash(yaml)
          Gitlab::Config::Loader::Yaml.new(yaml).load!
        end
      end
    end
  end
end
