# frozen_string_literal: true

# Load only in case we are running web_server or rails console
if Gitlab::Runtime.web_server? || Gitlab::Runtime.console?
  require 'web_engine'
end
