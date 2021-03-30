# frozen_string_literal: true

class MembersPreloader
  attr_reader :members

  def initialize(members)
    @members = members
  end

  def preload_all(admin: true)
    ActiveRecord::Associations::Preloader.new.preload(members, user: :managing_group)
    ActiveRecord::Associations::Preloader.new.preload(members, :created_by)
    ActiveRecord::Associations::Preloader.new.preload(members, :source)
    ActiveRecord::Associations::Preloader.new.preload(members, user: :status)

    if admin
      ActiveRecord::Associations::Preloader.new.preload(members.map(&:user), :u2f_registrations)
      ActiveRecord::Associations::Preloader.new.preload(members.map(&:user), :webauthn_registrations)
    end
  end
end

MembersPreloader.prepend_if_ee('EE::MembersPreloader')
