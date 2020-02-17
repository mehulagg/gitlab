# frozen_string_literal: true

module Gitlab
  module Ci
    class JwtAuth
      def self.jwt_for_job(job, ttl: 60)
        payload = self.new(job).payload(ttl: ttl)

        JWT.encode(
          payload,
          OpenSSL::PKey::RSA.new(Rails.application.secrets.openid_connect_signing_key),
          "RS256"
        )
      end

      def initialize(job)
        @job = job
      end

      def payload(ttl:)
        now = Time.now.to_i

        {
          # Issuer
          iss: Settings.gitlab.host,
          # Issued at
          iat: now,
          # Expiry at
          exp: now + ttl,
          # Subject
          sub: job.project.id.to_s,
          # Namespace
          nid: namespace_id,
          # User Id
          uid: job.user_id.to_s,
          # Project Id
          pid: job.project_id.to_s,
          # Job Id
          jid: job.id.to_s,
          # Ref name
          ref: job.ref,
          # Ref type is one of branch, tag, merge_request
          ref_type: ref_type,
          # Wildcards that protect the ref (empty list if none)
          protected: protected_refs,
          # Environment before expansion (if any)
          env: job.environment
        }
      end

      private

      attr_reader :job

      def namespace_id
        prefix = job.project.namespace.type.presence || 'user'

        "#{prefix.downcase}:#{job.project.namespace.id}"
      end

      def ref_type
        if job.branch?
          'branch'
        elsif job.tag?
          'tag'
        elsif job.merge_request?
          'merge_request'
        end
      end

      def protected_refs
        protected_refs = if job.branch?
                           job.project.protected_branches
                         elsif job.tag?
                           job.project.protected_tags
                         # elsif job.merge_request?
                         #   'merge_request'
                         end

        protected_refs.matching(job.ref).map(&:name)
      end
    end
  end
end
