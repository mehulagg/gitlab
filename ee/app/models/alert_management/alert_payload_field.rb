# frozen_string_literal: true

module AlertManagement
  class AlertPayloadField
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :project, :path, :label, :type

    SUPPORTED_TYPES = %w[string numeric datetime].freeze

    validates :project, presence: true
    validates :label, presence: true
    validates :type, inclusion: { in: SUPPORTED_TYPES }

    validate :path_is_list_of_strings

    private

    def path_is_list_of_strings
      unless path.is_a?(Array) && path.all? { |segment| segment.is_a?(String) }
        errors.add(:path, 'must be a list of strings')
      end
    end
  end
end
