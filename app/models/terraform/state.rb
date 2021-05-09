# frozen_string_literal: true

module Terraform
  class State < ApplicationRecord
    include UsageStatistics

    HEX_REGEXP = %r{\A\h+\z}.freeze
    UUID_LENGTH = 32

    belongs_to :project
    belongs_to :locked_by_user, class_name: 'User'

    has_many :versions,
      class_name: 'Terraform::StateVersion',
      foreign_key: :terraform_state_id,
      inverse_of: :terraform_state

    has_one :latest_version, -> { ordered_by_version_desc },
      class_name: 'Terraform::StateVersion',
      foreign_key: :terraform_state_id,
      inverse_of: :terraform_state

    scope :ordered_by_name, -> { order(:name) }
    scope :with_name, -> (name) { where(name: name) }

    validates :name, presence: true, uniqueness: { scope: :project_id }
    validates :project_id, presence: true
    validates :uuid, presence: true, uniqueness: true, length: { is: UUID_LENGTH },
              format: { with: HEX_REGEXP, message: 'only allows hex characters' }

    before_destroy :ensure_state_is_unlocked

    default_value_for(:uuid, allows_nil: false) { SecureRandom.hex(UUID_LENGTH / 2) }

    def latest_file
      latest_version&.file
    end

    def locked?
      self.lock_xid.present?
    end

    def update_file!(data, version:, build:)
      create_new_version!(data: data, version: version, build: build)
    end

    private

    def create_new_version!(data:, version:, build:)
      new_version = versions.build(version: version, created_by_user: locked_by_user, build: build)
      new_version.assign_attributes(file: data)
      new_version.save!
    end

    def ensure_state_is_unlocked
      return unless locked?

      errors.add(:base, s_("Terraform|You cannot remove the State file because it's locked. Unlock the State file first before removing it."))
      throw :abort # rubocop:disable Cop/BanCatchThrow
    end
  end
end

Terraform::State.prepend_if_ee('EE::Terraform::State')
