# frozen_string_literal: true

class AllowedEmailDomain < ApplicationRecord
  RESERVED_DOMAINS = [
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'aol.com',
    'msn.com',
    'hotmail.co.uk',
    'hotmail.fr',
    'live.com',
    'outlook.com',
    'icloud.com'
  ].freeze

  VALID_DOMAIN_REGEX = /\w*\./.freeze

  validates :group_id, presence: true
  validates :domain, presence: true
  validate :allow_root_group_only
  validates :domain, exclusion: { in: RESERVED_DOMAINS,
    message: _('The domain you entered is not allowed.') }
  validates :domain, format: { with: VALID_DOMAIN_REGEX,
    message: _('The domain you entered is misformatted.') }

  belongs_to :group, class_name: 'Group', foreign_key: :group_id

  class << self
    def domain_names
      pluck(:domain)
    end
  end

  def allow_root_group_only
    if group&.parent_id
      errors.add(:base, _('Allowed email domain restriction only permitted for top-level groups'))
    end
  end

  def email_matches_domain?(email)
    email.end_with?(email_domain)
  end

  def email_domain
    @email_domain ||= "@#{domain}"
  end
end
