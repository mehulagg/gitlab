# frozen_string_literal: true

class UserCanonicalEmail < NamespaceShard
  validates :canonical_email, presence: true
  validates :canonical_email, format: { with: Devise.email_regexp }

  belongs_to :user, inverse_of: :user_canonical_email
end
