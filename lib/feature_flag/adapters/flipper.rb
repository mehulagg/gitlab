# frozen_string_literal: true

require 'flipper/adapters/active_record'
require 'flipper/adapters/active_support_cache_store'

module FeatureFlag
  module Adapters
    class Flipper
      # Classes to override flipper table names
      class FlipperFeature < ::Flipper::Adapters::ActiveRecord::Feature
        # Using `self.table_name` won't work. ActiveRecord bug?
        superclass.table_name = 'features'

        def self.feature_names
          pluck(:key)
        end
      end

      class FlipperGate < ::Flipper::Adapters::ActiveRecord::Gate
        superclass.table_name = 'feature_gates'
      end

      class << self
        delegate :group, to: :flipper

        def available?
          true
        end
      
        def all
          flipper.features.to_a
        end

        def get(key)
          flipper.feature(key)
        end

        # This method is called from config/initializers/flipper.rb and can be used
        # to register Flipper groups.
        # See https://docs.gitlab.com/ee/development/feature_flags.html#feature-groups
        def register_feature_groups
        end

        def persisted?(feature)
          # Flipper creates on-memory features when asked for a not-yet-created one.
          # If we want to check if a feature has been actually set, we look for it
          # on the persisted features list.
          persisted_names.include?(feature.name.to_s)
        end

        def table_exists?
          FlipperFeature.table_exists?
        end

        private

        def flipper
          if Gitlab::SafeRequestStore.active?
            Gitlab::SafeRequestStore[:flipper] ||= build_flipper_instance
          else
            @flipper ||= build_flipper_instance
          end
        end

        def persisted_names
          Gitlab::SafeRequestStore[:flipper_persisted_names] ||=
            begin
              # We saw on GitLab.com, this database request was called 2300
              # times/s. Let's cache it for a minute to avoid that load.
              Gitlab::ThreadMemoryCache.cache_backend.fetch('flipper:persisted_names', expires_in: 1.minute) do
                FlipperFeature.feature_names
              end
            end
        end

        def build_flipper_instance
          ::Flipper.new(flipper_adapter).tap { |flip| flip.memoize = true }
        end

        def flipper_adapter
          active_record_adapter = ::Flipper::Adapters::ActiveRecord.new(
            feature_class: FlipperFeature,
            gate_class: FlipperGate)
    
          # Redis L2 cache
          redis_cache_adapter =
            ::Flipper::Adapters::ActiveSupportCacheStore.new(
              active_record_adapter,
              l2_cache_backend,
              expires_in: 1.hour)
    
          # Thread-local L1 cache: use a short timeout since we don't have a
          # way to expire this cache all at once
          ::Flipper::Adapters::ActiveSupportCacheStore.new(
            redis_cache_adapter,
            l1_cache_backend,
            expires_in: 1.minute)
        end

        def l1_cache_backend
          Gitlab::ThreadMemoryCache.cache_backend
        end
    
        def l2_cache_backend
          Rails.cache
        end
      end
    end
  end
end
