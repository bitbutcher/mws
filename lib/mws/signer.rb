class Mws::Signer

  def initialize(options={})
    @verb = (options[:method] || options[:verb] || 'POST').to_s.upcase
    @host = (options[:host] || 'mws.amazonservices.com').to_s.downcase
    @path = options[:path] || '/'
    @secret = options[:secret]
  end

  def signature(query, secret=@secret)
    digest = OpenSSL::Digest::Digest.new 'sha256'
    message = [ @verb, @host, @path, query ].join "\n"
    Base64::encode64(OpenSSL::HMAC.digest(digest, secret, message)).chomp
  end

  def sign(query, secret=@secret)
    "#{query}&Signature=#{Mws::Utils.uri_escape signature(query, secret)}"
  end

end
