# frozen_string_literal: true

module DastSiteProfiles
  class CreateService < BaseService
    def execute(name:, target_url:)
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      ActiveRecord::Base.transaction do
        service = DastSites::FindOrCreateService.new(project, current_user)
        dast_site = service.execute!(url: target_url)

        # key generation
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        secret_key = cipher.random_key
        secret_key_iv = cipher.random_iv

        # persist db record and encode/encrypt keys
        dast_site_profile = DastSiteProfile.create!(
          project: project,
          dast_site: dast_site,
          name: name,
          secret_key: Base64.encode64(secret_key),
          secret_key_iv: Base64.encode64(secret_key_iv)
        )

        # create new environment
        Environment.create!(
          project: project,
          name: dast_site_profile.environment_scope
        )

        # create username variable
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        cipher.key = secret_key
        cipher.iv = secret_key_iv

        Ci::Variable.create!(
          project_id: project.id,
          key: 'DAST_ENCRYPTED_USERNAME',
          value: Base64.encode64(cipher.update('username') + cipher.final).strip,
          masked: true,
          environment_scope: dast_site_profile.environment_scope
        )

        # create password variable
        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        cipher.encrypt
        cipher.key = secret_key
        cipher.iv = secret_key_iv

        Ci::Variable.create!(
          project_id: project.id,
          key: 'DAST_ENCRYPTED_PASSWORD',
          value: Base64.encode64(cipher.update('password') + cipher.final).strip,
          masked: true,
          environment_scope: dast_site_profile.environment_scope
        )

        # decipher = OpenSSL::Cipher.new('aes-256-cbc')
        # decipher.decrypt
        # decipher.key = secret_key
        # decipher.iv = secret_key_iv
        # decipher.update(cipher_text) + decipher.final

        ServiceResponse.success(payload: dast_site_profile)
      end

    rescue ActiveRecord::RecordInvalid => err
      ServiceResponse.error(message: err.record.errors.full_messages)
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
    end
  end
end
