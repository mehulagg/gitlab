# frozen_string_literal: true

# rubocop:disable Style/GlobalVars
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/cuprite'
require 'capybara-screenshot/rspec'
require 'selenium-webdriver'

# Give CI some extra time
timeout = (ENV['CI'] || ENV['CI_SERVER']) ? 60 : 30

# Define an error class for JS console messages
JSConsoleError = Class.new(StandardError)

# Filter out innocuous JS console messages
JS_CONSOLE_FILTER = Regexp.union([
  '"[HMR] Waiting for update signal from WDS..."',
  '"[WDS] Hot Module Replacement enabled."',
  '"[WDS] Live Reloading enabled."',
  'Download the Vue Devtools extension',
  'Download the Apollo DevTools'
])

CAPYBARA_WINDOW_SIZE = [1366, 768].freeze

Capybara.register_driver(:cuprite) do |app|
  options = {
    timeout: timeout,
    # Run headless by default unless CHROME_HEADLESS specified
    headless: ENV['CHROME_HEADLESS'] !~ /^(false|no|0)$/i,
    window_size: CAPYBARA_WINDOW_SIZE,
    browser_options: {
      # Chrome won't work properly in a Docker container in sandbox mode
      'no-sandbox': nil,
    }.tap do |options|
      if ENV['CI'] || ENV['CI_SERVER']
        options.merge!(
          # Disable /dev/shm use in CI. See https://gitlab.com/gitlab-org/gitlab/issues/4252
          'disable-dev-shm-usage': nil,
          # Explicitly set user-data-dir to prevent crashes. See https://gitlab.com/gitlab-org/gitlab-foss/issues/58882#note_179811508
          'user-data-dir': '/tmp/chrome'
        )
      end
    end
  }

  Capybara::Cuprite::Driver.new(app, options)
end

Capybara.server = :webrick
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = timeout
Capybara.ignore_hidden_elements = true
Capybara.default_normalize_ws = true
Capybara.enable_aria_label = true

# Keep only the screenshots generated from the last failing test suite
Capybara::Screenshot.prune_strategy = :keep_last_run
# From https://github.com/mattheworiordan/capybara-screenshot/issues/84#issuecomment-41219326
Capybara::Screenshot.register_driver(:cuprite) do |driver, path|
  driver.browser.save_screenshot(path)
end

RSpec.configure do |config|
  config.include CapybaraHelpers, type: :feature

  config.before(:context, :js) do
    next if $capybara_server_already_started

    TestEnv.eager_load_driver_server
    $capybara_server_already_started = true
  end

  config.before(:example, :js) do
    session = Capybara.current_session

    allow(Gitlab::Application.routes).to receive(:default_url_options).and_return(
      host: session.server.host,
      port: session.server.port,
      protocol: 'http')

    # reset window size between tests
    unless session.current_window.size == CAPYBARA_WINDOW_SIZE
      begin
        session.current_window.resize_to(*CAPYBARA_WINDOW_SIZE)
      rescue # ?
      end
    end
  end

  config.after(:example, :js) do |example|
    # when a test fails, display any messages in the browser's console
    # but fail don't add the message if the failure is a pending test that got
    # fixed. If we raised the `JSException` the fixed test would be marked as
    # failed again.
    if example.exception && !example.exception.is_a?(RSpec::Core::Pending::PendingExampleFixedError)
      console = page.driver.browser.manage.logs.get(:browser)&.reject { |log| log.message =~ JS_CONSOLE_FILTER }

      if console.present?
        message = "Unexpected browser console output:\n" + console.map(&:message).join("\n")
        raise JSConsoleError, message
      end
    end

    # prevent localStorage from introducing side effects based on test order
    unless ['', 'about:blank', 'data:,'].include? Capybara.current_session.driver.browser.current_url
      execute_script("localStorage.clear();")
    end

    # capybara/rspec already calls Capybara.reset_sessions! in an `after` hook,
    # but `block_and_wait_for_requests_complete` is called before it so by
    # calling it explicitly here, we prevent any new requests from being fired
    # See https://github.com/teamcapybara/capybara/blob/ffb41cfad620de1961bb49b1562a9fa9b28c0903/lib/capybara/rspec.rb#L20-L25
    # We don't reset the session when the example failed, because we need capybara-screenshot to have access to it.
    Capybara.reset_sessions! unless example.exception
    block_and_wait_for_requests_complete
  end
end
