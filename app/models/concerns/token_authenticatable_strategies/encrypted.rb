# frozen_string_literal: true

module TokenAuthenticatableStrategies
  class Encrypted < Base
    DYNAMIC_NONCE_IDENTIFIER = "|"

    def find_token_authenticatable(token, unscoped = false)
      return if token.blank?

      if required?
        find_by_encrypted_token(token, unscoped)
      elsif optional?
        find_by_encrypted_token(token, unscoped) ||
          find_by_plaintext_token(token, unscoped)
      elsif migrating?
        find_by_plaintext_token(token, unscoped)
      else
        raise ArgumentError, _("Unknown encryption strategy: %{encrypted_strategy}!") % { encrypted_strategy: encrypted_strategy }
      end
    end

    def ensure_token(instance)
      # TODO, tech debt, because some specs are testing migrations, but are still
      # using factory bot to create resources, it might happen that a database
      # schema does not have "#{token_name}_encrypted" field yet, however a bunch
      # of models call `ensure_#{token_name}` in `before_save`.
      #
      # In that case we are using insecure strategy, but this should only happen
      # in tests, because otherwise `encrypted_field` is going to exist.
      #
      # Another use case is when we are caching resources / columns, like we do
      # in case of ApplicationSetting.

      return super if instance.has_attribute?(encrypted_field)

      if required?
        raise ArgumentError, _('Using required encryption strategy when encrypted field is missing!')
      else
        insecure_strategy.ensure_token(instance)
      end
    end

    def get_token(instance)
      return insecure_strategy.get_token(instance) if migrating?

      encrypted_token = instance.read_attribute(encrypted_field)
      token = decrypt_token(encrypted_token)
      token || (insecure_strategy.get_token(instance) if optional?)
    end

    def set_token(instance, token)
      raise ArgumentError unless token.present?

      instance[encrypted_field] = form_encrypted_token(token)
      instance[token_field] = token if migrating?
      instance[token_field] = nil if optional?
      token
    end

    def required?
      encrypted_strategy == :required
    end

    def migrating?
      encrypted_strategy == :migrating
    end

    def optional?
      encrypted_strategy == :optional
    end

    protected

    def encrypted_strategy
      value = options[:encrypted]
      value = value.call if value.is_a?(Proc)

      unless value.in?([:required, :optional, :migrating])
        raise ArgumentError, _('encrypted: needs to be a :required, :optional or :migrating!')
      end

      value
    end

    def find_by_plaintext_token(token, unscoped)
      insecure_strategy.find_token_authenticatable(token, unscoped)
    end

    def find_by_encrypted_token(token, unscoped)
      encrypted_value = form_encrypted_token(token)

      relation(unscoped).find_by(encrypted_field => encrypted_value)
    end

    def form_encrypted_token(token)
      iv = ::Digest::SHA256.hexdigest(token).bytes.take(12).pack('c*')
      token = Gitlab::CryptoHelper.aes256_gcm_encrypt(token, nonce: iv)
      "#{DYNAMIC_NONCE_IDENTIFIER}#{token}#{iv}"
    end

    def decrypt_token(encrypted_token)
      if encrypted_token[0] == DYNAMIC_NONCE_IDENTIFIER
        iv = encrypted_token[-12..-1]
        token = encrypted_token[1...-12]
        Gitlab::CryptoHelper.aes256_gcm_decrypt(token, nonce: iv)
      else
        Gitlab::CryptoHelper.aes256_gcm_decrypt(encrypted_token, nonce: Gitlab::CryptoHelper::AES256_GCM_IV_STATIC)
      end
    end

    def insecure_strategy
      @insecure_strategy ||= TokenAuthenticatableStrategies::Insecure
        .new(klass, token_field, options)
    end

    def token_set?(instance)
      raw_token = instance.read_attribute(encrypted_field)

      unless required?
        raw_token ||= insecure_strategy.get_token(instance)
      end

      raw_token.present?
    end

    def encrypted_field
      @encrypted_field ||= "#{@token_field}_encrypted"
    end
  end
end
