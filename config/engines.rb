# frozen_string_literal: true

# Load only in case we are running web_server or rails console
test_web_engine = Gitlab::Utils.to_boolean(ENV['TEST_WEB_ENGINE'], default: false)

if Gitlab::Runtime.web_server? || Gitlab::Runtime.console? || test_web_engine
  require 'web_engine'
end

ActiveSupport::Notifications.subscribe "load_config_initializer.railties" do |name, started, finished, unique_id, data|
  # puts data.inspect # {:this=>:data}
  # puts name
end
