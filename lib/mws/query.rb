require 'time'

class Mws::Query

  def initialize(options)
    options[:aws_access_key_id] ||= options.delete :access
    options[:marketplace] ||= options.delete(:market) || 'ATVPDKIKX0DER'
    options[:signature_method] ||= 'HmacSHA256'
    options[:signature_version] ||= '2'
    options[:timestamp] ||= Time.now.iso8601
    options[:version] ||= '2009-01-01'
    @params = Hash[options.inject({}) do | params, entry |
      params[normalize_key entry.first] = normalize_val entry.last
      params
    end.sort]
  end

  def to_s
    @params.map { |it| it.join '=' }.join '&'
  end

  private

  def normalize_key(key)
    Mws::Utils.camelize(key).sub /^Aws/, 'AWS'
  end

  def normalize_val(value)
    URI::encode(value.respond_to?(:iso8601) ? value.iso8601 : value)
  end

end
