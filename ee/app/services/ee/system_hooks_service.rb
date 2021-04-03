# frozen_string_literal: true

module EE
  module SystemHooksService
    extend ::Gitlab::Utils::Override

    private

    override :user_data
    def user_data(model)
      super.tap do |data|
        data.merge!(email_opted_in_data(model)) if ::Gitlab.com?
      end
    end

    def email_opted_in_data(model)
      {
        email_opted_in: model.email_opted_in,
        email_opted_in_ip: model.email_opted_in_ip,
        email_opted_in_source: model.email_opted_in_source,
        email_opted_in_at: model.email_opted_in_at
      }
    end
  end
end
