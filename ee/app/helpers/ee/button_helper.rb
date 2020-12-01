# frozen_string_literal: true

module EE
  module ButtonHelper
    extend ::Gitlab::Utils::Override

    override :ssh_clone_button
    def ssh_clone_button(container, append_link: true)
      return super unless ::Gitlab::Geo.secondary?

      if ::Gitlab::CurrentSettings.user_show_add_ssh_key_message? &&
          current_user.try(:require_ssh_key?)
        dropdown_description = s_("MissingSSHKeyWarningLink|You won't be able to pull or push repositories via SSH until you add an SSH key to your profile")
      end

      append_url = container.ssh_url_to_repo if append_link
      geo_url = geo_primary_http_url_to_repo(container)

      dropdown_item_with_description('SSH', dropdown_description, href: append_url, data: { primary_url: geo_url, clone_type: 'ssh' })
    end

    override :http_clone_button
    def http_clone_button(container, append_link: true)
      return super unless ::Gitlab::Geo.secondary?

      protocol = gitlab_config.protocol.upcase
      dropdown_description = http_dropdown_description(protocol)
      append_url = container.http_url_to_repo if append_link
      geo_url = geo_primary_http_url_to_repo(container)

      dropdown_item_with_description(protocol, dropdown_description, href: append_url, data: { primary_url: geo_url, clone_type: 'http' })
    end

    def kerberos_clone_button(container)
      klass = 'kerberos-selector has-tooltip'

      content_tag :a, 'KRB5',
        class: klass,
        href: container.kerberos_url_to_repo,
        data: {
          html: 'true',
          placement: 'right',
          container: 'body',
          title: 'Get a Kerberos token for your<br>account with kinit.'
        }
    end
  end
end
