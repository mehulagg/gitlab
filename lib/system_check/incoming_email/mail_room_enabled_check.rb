# frozen_string_literal: true

module SystemCheck
  module IncomingEmail
    class MailRoomEnabledCheck < SystemCheck::BaseCheck
      set_name 'Mailroom enabled?'

      def skip?
        omnibus_gitlab?
      end

      def check?
        mail_room_enabled? || mail_room_configured?
      end

      def show_error
        try_fixing_it(
          'Enable mail_room'
        )
        for_more_information(
          'doc/administration/reply_by_email.md'
        )
        fix_and_rerun
      end

      private

      def mail_room_enabled?
        target = '/usr/lib/systemd/system/gitlab.target'
        service = '/usr/lib/systemd/system/gitlab-mailroom.service'
        wants = '/usr/lib/systemd/system/gitlab.target.wants/gitlab-mailroom.service'

        File.exist?(target) && File.exist?(service) && File.symlink?(wants)
      end

      def mail_room_configured?
        path = '/etc/default/gitlab'
        File.exist?(path) && File.read(path).include?('mail_room_enabled=true')
      end
    end
  end
end
