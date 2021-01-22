# frozen_string_literal: true

# Monkey patch Net::HTTP to fix missing URL decoding for username and password in proxy settings
#
# See proposed upstream fix https://github.com/ruby/net-http/pull/5
# See Ruby-lang issue https://bugs.ruby-lang.org/issues/17542
# See issue on GitLab https://gitlab.com/gitlab-org/gitlab/-/issues/289836

module Net
  class HTTP < Protocol
    def proxy_user
      if ENVIRONMENT_VARIABLE_IS_MULTIUSER_SAFE && @proxy_from_env
        user = proxy_uri&.user
        URI.decode_www_form_component(user, Encoding::ASCII) unless user.nil?
      else
        @proxy_user
      end
    end

    def proxy_pass
      if ENVIRONMENT_VARIABLE_IS_MULTIUSER_SAFE && @proxy_from_env
        pass = proxy_uri&.password
        URI.decode_www_form_component(pass, Encoding::ASCII) unless pass.nil?
      else
        @proxy_pass
      end
    end
  end
end
