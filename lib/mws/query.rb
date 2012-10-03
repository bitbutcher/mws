require 'time'

class Mws::Query

  def initialize(options)
    @params = {}
    @params['Action'] = options[:action]
    @params['AWSAccessKeyId'] = options[:access]
    @params['Merchant'] = options[:merchant]
    @params['Marketplace'] = options[:market] || 'ATVPDKIKX0DER'
    @params['SignatureMethod'] = 'HmacSHA256'
    @params['SignatureVersion'] = '2'
    @params['Timestamp'] = Time.now.iso8601
    @params['Version'] = '2009-01-01'
    options[:params].each do | key, value |
      @params[normalize_key key] = normalize_val value
    end if options[:params]
    @params = Hash[@params.sort]
  end

  def to_s
    @params.map { |it| it.join '=' }.join '&'
  end

  private

  def normalize_key(key)
    Mws::Utils.camelize(key).sub /^Aws/, 'AWS'
  end

  def normailze_val(value)
    URI::encode(value.responds_to?(:iso8601) ? value.iso8601 : value)
  end

end
