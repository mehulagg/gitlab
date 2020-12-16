# frozen_string_literal: true

module Groups
  class PackageSetting < ApplicationRecord
    self.primary_key = :group_id
    self.table_name = 'group_package_settings'

    belongs_to :group, inverse_of: :package_setting

    validates :group, presence: true
    validates :maven_duplicates_allowed, inclusion: { in: [true, false] }
    validates :maven_duplicate_exception_regex, untrusted_regexp: true
  end
end
