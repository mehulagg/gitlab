# frozen_string_literal: true

module NotifyHelper
  def merge_request_reference_link(entity, *args)
    link_to(entity.to_reference, merge_request_url(entity, *args))
  end

  def issue_reference_link(entity, *args, full: false)
    link_to(entity.to_reference(full: full), issue_url(entity, *args))
  end

  def invited_role_description(role_name)
    case role_name
    when "Guest"
      s_("InviteEmail|Guests are not active contributors in private projects. They can only see, and leave comments and issues. %{learn_more}.")
    when "Reporter"
      s_("InviteEmail|Reporters are read-only contributors. They can't write to the repository, but can on issues. %{learn_more}.")
    when "Developer"
      s_("InviteEmail|Developers are direct contributors of a group. They have access to all the feature to go from idea to production. %{learn_more}.")
    when "Maintainer"
      s_("InviteEmail|Maintainers are super-developers. They are able to push to master, deploy to production. %{learn_more}.")
    end
  end

  def invited_to_description(source)
    case source
    when "project"
      s_('InviteEmail|Projects can be used to host your code, track issues, collaborate on code, and continuously build, test, and deploy your app with built-in GitLab CI/CD.')
    when "group"
      s_('InviteEmail|Groups assemble related projects together and grant members access to several projects at once.')
    end
  end
end
