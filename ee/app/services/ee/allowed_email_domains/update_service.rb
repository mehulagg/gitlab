# frozen_string_literal: true

module EE
  # This class is responsible for updating the allowed_email_domains of a specific group.
  # It takes in comma separated domains as input, eg: 'acme.com, acme.co.in'

  # For a group with existing allowed_email_domains records, this service:
  # marks the `allowed_email_domains` records that exist for the group right now, but are not in `comma_separated_domains` for deletion.
  # builds new `allowed_email_domains` records that do not exist for the group right now, but exists in `comma_separated_domains`
  module AllowedEmailDomains
    class UpdateService
      include ::Gitlab::Utils::StrongMemoize
      include ::Gitlab::Allowable

      def initialize(current_user, group, comma_separated_domains)
        @current_user = current_user
        @group = group
        @current_domains = comma_separated_domains.split(",").map(&:strip).uniq
      end

      def execute
        return unless domains_changed?

        unless can?(current_user, :admin_group, group)
          group.errors.add(:allowed_email_domains, s_('GroupSettings|cannot be changed by you'))
          return
        end

        mark_deleted_allowed_email_domains_for_destruction
        build_new_allowed_emails_domains_records
      end

      private

      attr_reader :current_user, :group, :current_domains

      def mark_deleted_allowed_email_domains_for_destruction
        return unless domains_to_be_deleted.present?

        group.allowed_email_domains.each do |allowed_email_domain|
          if domains_to_be_deleted.include?(allowed_email_domain.domain)
            allowed_email_domain.mark_for_destruction
          end
        end
      end

      def build_new_allowed_emails_domains_records
        return unless domains_to_be_created.present?

        domains_to_be_created.each do |domain|
          group.allowed_email_domains.build(domain: domain)
        end
      end

      def domains_to_be_deleted
        strong_memoize(:domains_to_be_deleted) do
          existing_domains - current_domains
        end
      end

      def domains_to_be_created
        strong_memoize(:domains_to_be_created) do
          current_domains - existing_domains
        end
      end

      def existing_domains
        strong_memoize(:existing_domains) do
          group.allowed_email_domains.domain_names
        end
      end

      def domains_changed?
        existing_domains.sort != current_domains.sort
      end
    end
  end
end
