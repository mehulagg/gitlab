# frozen_string_literal: true

module MembersPresentation
  extend ActiveSupport::Concern

  def present_members(members, admin: true)
    preload_associations(members, admin)

    Gitlab::View::Presenter::Factory.new(
      members,
      current_user: current_user,
      presenter_class: MembersPresenter
    ).fabricate!
  end

  def preload_associations(members, admin)
    MembersPreloader.new(members).preload_all(admin: admin)
  end
end
