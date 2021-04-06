# frozen_string_literal: true

module SchemaPath
  def self.expand(schema, dir = nil)
    return schema unless schema.is_a?(String)

    if Gitlab.ee? && dir.nil?
      ee_path = expand(schema, 'ee')

      return ee_path if File.exist?(ee_path)
    end

    Rails.root.join(dir.to_s, 'spec', "fixtures/api/schemas/#{schema}.json").to_s
  end
end

RSpec::Matchers.define :match_response_schema do |schema, dir: nil, **options|
  file_ref_resolver = proc do |uri|
    file = Rails.root.join(uri.path)
    raise StandardError, "Ref file #{uri.path} must be json" unless uri.path.ends_with?('.json')
    raise StandardError, "File #{file.to_path} doesn't exists" unless file.exist?

    Gitlab::Json.parse(File.read(file))
  end

  match do |response|
    schema_path = Pathname.new(SchemaPath.expand(schema, dir))

    validator = JSONSchemer.schema(schema_path, ref_resolver: file_ref_resolver)
    validator.valid?(Gitlab::Json.parse(response.body))
  end
end

RSpec::Matchers.define :match_schema do |schema, dir: nil, **options|
  file_ref_resolver = proc do |uri|
    file = Rails.root.join(uri.path)
    raise StandardError, "Ref file #{uri.path} must be json" unless uri.path.ends_with?('.json')
    raise StandardError, "File #{file.to_path} doesn't exists" unless file.exist?

    Gitlab::Json.parse(File.read(file))
  end

  match do |data|
    schema_path = Pathname.new(SchemaPath.expand(schema, dir))
    validator = JSONSchemer.schema(schema_path, ref_resolver: file_ref_resolver)
    validator.valid?(Gitlab::Json.parse(response.body))
  end
end
