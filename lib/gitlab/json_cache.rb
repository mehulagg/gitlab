# frozen_string_literal: true

module Gitlab
  class JsonCache
    attr_reader :backend, :cache_key_with_version, :namespace

    def initialize(options = {})
      @backend = options.fetch(:backend, Rails.cache)
      @namespace = options.fetch(:namespace, nil)
      @cache_key_with_version = options.fetch(:cache_key_with_version, true)
    end

    def active?
      if backend.respond_to?(:active?)
        backend.active?
      else
        true
      end
    end

    def cache_key(key)
      expanded_cache_key = [namespace, key].compact

      if cache_key_with_version
        expanded_cache_key << Rails.version
      end

      expanded_cache_key.join(':')
    end

    def expire(key)
      backend.delete(cache_key(key))
    end

    def read(key, klass = nil)
      value = backend.read(cache_key(key))
      value = parse_value(value, klass) if value
      value
    end

    def write(key, value, options = nil)
      backend.write(cache_key(key), value.to_json, options)
    end

    def fetch(key, options = {}, &block)
      klass = options.delete(:as)
      value = read(key, klass)

      return value unless value.nil?

      value = yield

      write(key, value, options)

      value
    end

    private

    def parse_value(raw, klass)
      value = ActiveSupport::JSON.decode(raw)

      case value
      when Hash then parse_entry(value, klass)
      when Array then parse_entries(value, klass)
      else
        value
      end
    rescue ActiveSupport::JSON.parse_error
      nil
    end

    def parse_entry(raw, klass)
      return unless valid_entry?(raw, klass)
      return klass.new(raw) unless klass.ancestors.include?(ActiveRecord::Base)

      # When the cached value is a persisted instance of ActiveRecord::Base in
      # some cases a relation can return an empty collection becauses scope.none!
      # is being applied on ActiveRecord::Associations::CollectionAssociation#scope
      # when the new_record? method incorrectly returns false.
      #
      # See https://gitlab.com/gitlab-org/gitlab-ee/issues/9903#note_145329964
      attributes = klass.attributes_builder.build_from_database(raw, {})
      klass.allocate.init_with("attributes" => attributes, "new_record" => new_record?(raw, klass))
    end

    def new_record?(raw, klass)
      raw.fetch(klass.primary_key, nil).blank?
    end

    def valid_entry?(raw, klass)
      return false unless klass && raw.is_a?(Hash)

      (raw.keys - klass.attribute_names).empty?
    end

    def parse_entries(values, klass)
      values.map { |value| parse_entry(value, klass) }.compact
    end
  end
end
