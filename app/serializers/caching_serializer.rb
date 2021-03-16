# frozen_string_literal: true

# This is a serializer extension which returns JSON directly,
# rather than a hash from .as_json. Objects are cached
# using their cache_key.

class CachingSerializer < BaseSerializer
  def represent(resource, opts = {}, entity_class = nil)
    cache_opts = opts.delete(:cache)
    cache_opts[:context] ||= -> (resource) { cache_context(resource) }

    return super(resource, opts, entity_class) if cache_opts.nil?

    rendered = Gitlab::Utils::Caching.fetch_multi([resource], cache_opts) do |object|
      Gitlab::Json.dump(super(object, opts, entity_class))
    end

    return precompiled(rendered.first) if rendered.length == 1

    precompiled(rendered.values)
  end

  private

  def precompiled(values)
    Gitlab::Json::PrecompiledJson.new(values)
  end

  def cache_context(resource)
  end
end
