# frozen_string_literal: true
module EE
  module Gitlab
    module HookData
      module UserBuilder
        extend ::Gitlab::Utils::Override

        # Sample data
        # {
        # :created_at=>"2021-04-02T09:56:49Z",
        # :updated_at=>"2021-04-02T09:56:49Z",
        # :event_name=>"user_create",
        # :name=>"John Doe",
        # :email=>"john@example.com",
        # :user_id=>2,
        # :username=>"johndoe",
        # :email_opted_in=>"john@example.com",
        # :email_opted_in_ip=>"192.168.1.1",
        # :email_opted_in_source=>"Gitlab.com",
        # :email_opted_in_at=>"2021-03-31T10:30:58Z"
        # }

        private

        override :user_data
        def user_data
          super.tap do |data|
            data.merge!(email_opted_in_data) if ::Gitlab.com?
          end
        end

        def email_opted_in_data
          {
            email_opted_in: user.email_opted_in,
            email_opted_in_ip: user.email_opted_in_ip,
            email_opted_in_source: user.email_opted_in_source,
            email_opted_in_at: user.email_opted_in_at
          }
        end
      end
    end
  end
end
