# frozen_string_literal: true

module JsonbStoreAccessor
  extend ActiveSupport::Concern

  # Helps make alternative_status_store_accessor act more like regular Rails
  # attributes. Request params values are always strings, but when saved as
  # attributes of a model, they are converted to the appropriate types. We could
  # manually map a specified type to each attribute, but for now, the type can
  # be easily inferred by the attribute name.
  #
  # If you add a new status attribute that does not look like existing
  # attributes, then you'll get an error until you handle it in the cases below.
  #
  # @param [String] attr_name the status key
  # @param [String, Integer, Boolean] val being assigned or retrieved
  # @return [String, Integer, Boolean] converted value based on attr_name
  def convert_status_value(attr_name, val)
    return if val.nil?

    case attr_name
    when /_count\z/ then val.to_i
    when /_enabled\z/ then val.to_s == 'true'
    else raise "Unhandled status attribute name format \"#{attr_name}\""
    end
  end

  class_methods do
    def jsonb_store_accessor(store, attr_names)
      attr_names.each do |attr_name|
        define_method(attr_name) do
          # In order to make this compatible with multiple store names, we need
          # `send`
          # rubocop: disable GitlabSecurity/PublicSend
          val = send(store)[attr_name]
          # rubocop: enable GitlabSecurity/PublicSend

          # Backwards-compatible line for when the store was written by an
          # earlier release without the `status` field
          val ||= read_attribute(attr_name)

          convert_status_value(attr_name, val)
        end

        define_method("#{attr_name}=") do |val|
          val = convert_status_value(attr_name, val)

          # In order to make this compatible with multiple store names, we need
          # `send`
          # rubocop: disable GitlabSecurity/PublicSend
          send(store)[attr_name] = val
          # rubocop: enable GitlabSecurity/PublicSend
        end
      end
    end
  end
end
