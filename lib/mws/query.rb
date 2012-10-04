require 'time'

class Mws::Query

  def initialize(options)
    options[:aws_access_key_id] ||= options.delete :access
    options[:seller_id] ||= options.delete(:merchant) || options.delete(:seller)
    options[:marketplace_id] ||= [ options.delete(:markets) || options.delete(:market) || 'ATVPDKIKX0DER' ].flatten
    options[:signature_method] ||= 'HmacSHA256'
    options[:signature_version] ||= '2'
    options[:timestamp] ||= Time.now.iso8601
    options[:version] ||= '2009-01-01'
    @params = Hash[options.inject({}) do | params, entry |
      key = normalize_key entry.first
      if entry.last.respond_to? :each_with_index
        ext = entry.first.to_s.split('_').last.capitalize
        entry.last.each_with_index do | value, index |
          params["#{key}.#{ext}.#{index + 1}"] = normalize_val value
        end
      else
        params[key] = normalize_val entry.last
      end
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
    Mws::Utils.uri_escape(value.respond_to?(:iso8601) ? value.iso8601 : value)
  end

end
