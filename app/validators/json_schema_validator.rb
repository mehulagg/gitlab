# frozen_string_literal: true
#
# JsonSchemaValidator
#
# Custom validator for json schema.
# Create a json schema within the json_schemas directory
#
#   class Project < ActiveRecord::Base
#     validates :data, json_schema: { filename: "file" }
#   end
#
class JsonSchemaValidator < ActiveModel::EachValidator
  FILENAME_ALLOWED = /\A[a-z0-9_-]*\Z/.freeze
  FilenameError = Class.new(StandardError)
  JSON_VALIDATOR_MAX_DRAFT_VERSION = 4
  BASE_DIRECTORY = %w(app validators json_schemas).freeze

  def initialize(options)
    raise ArgumentError, "Expected 'filename' as an argument" unless options[:filename]
    raise FilenameError, "Must be a valid 'filename'" unless options[:filename].match?(FILENAME_ALLOWED)

    @base_directory = options.delete(:base_directory) || BASE_DIRECTORY

    super(options)
  end

  def validate_each(record, attribute, value)
    unless valid_schema?(value)
      record.errors.add(attribute, "must be a valid json schema")
    end
  end

  private

  attr_reader :base_directory

  def valid_schema?(value)
    if draft_version > JSON_VALIDATOR_MAX_DRAFT_VERSION
      JSONSchemer.schema(Pathname.new(schema_path)).valid?(value)
    else
      JSON::Validator.validate(schema_path, value)
    end
  end

  def schema_path
    @schema_path ||= Rails.root.join(*base_directory, filename_with_extension).to_s
  end

  def filename_with_extension
    "#{options[:filename]}.json"
  end

  def draft_version
    options[:draft] || JSON_VALIDATOR_MAX_DRAFT_VERSION
  end
end

JsonSchemaValidator.prepend_ee_mod
