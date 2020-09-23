# frozen_string_literal: true

module EE
  module Wiki
    extend ActiveSupport::Concern

    # No need to have a Kerberos Web url. Kerberos URL will be used only to
    # clone
    def kerberos_url_to_repo
      [::Gitlab.config.build_gitlab_kerberos_url, '/', full_path, '.git'].join('')
    end
  end
end
