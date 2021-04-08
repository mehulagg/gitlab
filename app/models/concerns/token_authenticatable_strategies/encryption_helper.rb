# frozen_string_literal: true

module TokenAuthenticatableStrategies
  class EncryptionHelper
    DYNAMIC_NONCE_IDENTIFIER = "|"
    NONCE_SIZE = 12

    def self.encrypt_token(token)
      return Gitlab::CryptoHelper.aes256_gcm_encrypt(token) unless Feature.enabled?(:dynamic_nonce, type: :ops)

      iv = ::Digest::SHA256.hexdigest(token).bytes.take(NONCE_SIZE).pack('c*')
      token = Gitlab::CryptoHelper.aes256_gcm_encrypt(token, nonce: iv)
      "#{DYNAMIC_NONCE_IDENTIFIER}#{token}#{iv}"
    end

    def self.decrypt_token(encrypted_token)
      return unless encrypted_token

      if encrypted_token[0] == DYNAMIC_NONCE_IDENTIFIER && encrypted_token.size > NONCE_SIZE + 1
        iv = encrypted_token[-NONCE_SIZE..-1]
        token = encrypted_token[1...-NONCE_SIZE]
        Gitlab::CryptoHelper.aes256_gcm_decrypt(token, nonce: iv)
      else
        Gitlab::CryptoHelper.aes256_gcm_decrypt(encrypted_token, nonce: Gitlab::CryptoHelper::AES256_GCM_IV_STATIC)
      end
    end
  end
end
