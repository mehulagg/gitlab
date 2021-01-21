# frozen_string_literal: true

module EE
  module StubConfiguration
    def stub_ee_application_setting(messages)
      add_predicates(messages)

      # Stubbing both of these because we're not yet consistent with how we access
      # current application settings
      allow_any_instance_of(EE::ApplicationSetting).to receive_messages(to_settings(messages))
      allow(::Gitlab::CurrentSettings.current_application_settings)
        .to receive_messages(to_settings(messages))

      # Ensure that we don't use the Markdown cache when stubbing these values
      allow_any_instance_of(EE::ApplicationSetting).to receive(:cached_html_up_to_date?).and_return(false)
    end

    def stub_application_setting_on_object(object, messages)
      add_predicates(messages)

      allow(::Gitlab::CurrentSettings.current_application_settings)
        .to receive_messages(messages)

      messages.each do |setting, value|
        allow(object).to receive_message_chain(:current_application_settings, setting) { value }
      end
    end

    def stub_geo_setting(messages)
      allow(::Gitlab.config.geo).to receive_messages(to_settings(messages))
    end

    def stub_smartcard_setting(messages)
      allow(::Gitlab.config.smartcard).to receive_messages(to_settings(messages))
    end

    def stub_elasticsearch_setting(messages)
      allow(::Gitlab.config.elasticsearch).to receive_messages(to_settings(messages))
    end
  end
end
