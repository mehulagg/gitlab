# frozen_string_literal: true

class Packages::Event < ApplicationRecord
  belongs_to :package, optional: true

  EVENT_SCOPES = ::Packages::Package::PACKAGE_TYPES.merge(container: 1000, tag: 1001).freeze

  enum event_scope: EVENT_SCOPES

  enum event_type: {
    push_package: 0,
    delete_package: 1,
    pull_package: 2,
    search_package: 3,
    list_package: 4,
    list_repositories: 5,
    delete_repository: 6,
    delete_tag: 7,
    delete_tag_bulk: 8,
    list_tags: 9,
    package_metadata: 10
  }

  enum originator_type: { user: 0, deploy_token: 1, guest: 2 }

  scope :with_scope, -> (scope) { where(scope: scope) }
  scope :with_user, -> { where(originator_type: :user) }
  scope :with_deploy_token, -> { where(originator_type: :deploy_token) }
  scope :with_guest, -> { where(originator_type: :guest) }
end
