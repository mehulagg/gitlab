# frozen_string_literal: true

class IpRestriction < NamespaceShard
  INVALID_SUBNET_ERRORS = [IPAddr::AddressFamilyError,
                           IPAddr::InvalidAddressError].freeze

  belongs_to :group

  validates :group_id, presence: true
  validates :range, presence: true
  validate :valid_subnet
  validate :allow_root_group_only

  def allows_address?(address)
    IPAddr.new(range).include?(address)
  rescue *INVALID_SUBNET_ERRORS
    false
  end

  private

  def valid_subnet
    IPAddr.new(range)
  rescue *INVALID_SUBNET_ERRORS
    errors.add(:range, _('is an invalid IP address range'))
  end

  def allow_root_group_only
    if group&.parent_id
      errors.add(:base, _('IP subnet restriction only allowed for top-level groups'))
    end
  end
end
