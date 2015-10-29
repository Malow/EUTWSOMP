module AESEncryption
  def self.encrypt(msg)
    key, iv = get_key_iv
    e = OpenSSL::Cipher.new('AES-256-OFB')
    e.encrypt
    e.key = key
    e.iv  = iv
    encrypted = '' << e.update(msg) << e.final
    Base64.strict_encode64(encrypted)
  end  
  
  def self.decrypt(msg)
    key, iv = get_key_iv
    d = OpenSSL::Cipher.new('AES-256-OFB')
    d.decrypt
    d.key = key
    d.iv  = iv
    decrypted = d.update(Base64.decode64(msg))
    decrypted << d.final
    decrypted
  end  
  
  private
  
  def self.get_key_iv
    e = OpenSSL::Cipher.new('AES-256-OFB')
    e.encrypt
    key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(Rails.application.secrets.aes_password, "", 1000, e.key_len+e.iv_len)
    key = key_iv[0, e.key_len]
    iv  = key_iv[e.key_len, e.iv_len]
    return key, iv
  end
end