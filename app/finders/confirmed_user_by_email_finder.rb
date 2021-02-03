# frozen_string_literal: true

class ConfirmedUserByEmailFinder
  def initialize(scope = User)
    @scope = scope
  end

  def find(email)
    return unless email

    by_primary_email(email) || by_confirmed_secondary_email(email)
  end

  def by_primary_email(email)
    scope.confirmed.find_by(email: email)
  end

  def by_confirmed_secondary_email(email)
    scope
      .confirmed
      .where.not(emails: { confirmed_at: nil })
      .by_emails(email)
      .first
  end
end
