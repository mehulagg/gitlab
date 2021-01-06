# frozen_string_literal: true

module AlertManagement
  class AlertPayloadField
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :project, :path, :label, :type

    validates :project, presence: true
    validates :path, presence: true
    validates :label, presence: true
    validates :type, presence: true
  end
end
