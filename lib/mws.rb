autoload :Base64, 'base64'
autoload :OpenSSL, 'openssl'
autoload :URI, 'open-uri'

module Mws

	autoload :Query, 'mws/query'
  autoload :Signer, 'mws/signer'
  autoload :Utils, 'mws/utils'

  # The current version of this ruby gem
  VERSION = '0.0.1'

end
