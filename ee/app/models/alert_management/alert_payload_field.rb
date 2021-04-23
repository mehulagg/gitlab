# frozen_string_literal: true

module AlertManagement
  class AlertPayloadField
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :project, :path, :label, :type, :field_name

    ARRAY_TYPE = 'array'
    DATETIME_TYPE = 'datetime'
    STRING_TYPE = 'string'
    SUPPORTED_TYPES = [ARRAY_TYPE, DATETIME_TYPE, STRING_TYPE].freeze

    validates :project, presence: true
    validates :label, presence: true
    validates :type, inclusion: { in: SUPPORTED_TYPES }

    validate :valid_path

    private

    def valid_path
      return if valid_path?

      errors.add(:path, 'must be a list of strings or integers')
    end

    def valid_path?
      path.is_a?(Array) && !path.empty? && valid_path_elements?(path)
    end

    def valid_path_elements?(path)
      path.all? { |segment| segment.is_a?(String) || segment.is_a?(Integer) }
    end
  end
end
