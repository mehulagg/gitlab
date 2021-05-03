# frozen_string_literal: true

module Gitlab
  module Email
    module Message
      module InProductMarketing
        UnknownEmailError = Class.new(StandardError)

        def self.for(track)
          case track
          when :create
            Gitlab::Email::Message::InProductMarketing::Create
          when :verify
            Gitlab::Email::Message::InProductMarketing::Verify
          when :team
            Gitlab::Email::Message::InProductMarketing::Team
          when :trial
            Gitlab::Email::Message::InProductMarketing::Trial
          else
            raise UnknownEmailError
          end
        end
      end
    end
  end
end
