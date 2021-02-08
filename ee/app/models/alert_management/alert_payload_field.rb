# frozen_string_literal: true

module AlertManagement
  class AlertPayloadField
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :project, :path, :label, :type

    ARRAY_TYPE = 'array'
    DATETIME_TYPE = 'datetime'
    STRING_TYPE = 'string'
    SUPPORTED_TYPES = [ARRAY_TYPE, DATETIME_TYPE, STRING_TYPE].freeze

    validates :project, presence: true
    validates :label, presence: true
    validates :type, inclusion: { in: SUPPORTED_TYPES }

    validate :ensure_path_is_non_empty_list_of_strings

    private

    def ensure_path_is_non_empty_list_of_strings
      return if path_is_non_empty_list_of_strings?

      errors.add(:path, 'must be a list of strings')
    end

    def path_is_non_empty_list_of_strings?
      path.is_a?(Array) && !path.empty? && path.all? { |segment| segment.is_a?(String) }
    end
  end
end
