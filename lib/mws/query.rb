require 'time'

class Mws::Query

  def initialize(overrides)
    options = {
      signature_method: 'HmacSHA256',
      signature_version: '2',
      timestamp: Time.now.iso8601,
      list_pattern: '%{key}List.%{ext}.%<index>d'
    }.merge overrides

    options[:aws_access_key_id] ||= options.delete :access
    options[:seller_id] ||= options.delete(:merchant) || options.delete(:seller)
    options[:marketplace_id] ||= options.delete(:markets) || []
    list_pattern = options.delete(:list_pattern) 

    @params = Hash[options.inject({}) do | params, entry |
      # puts "Entry: #{entry.inspect}"
      key = normalize_key entry.first
      if entry.last.respond_to? :each_with_index
        entry.last.each_with_index do | value, index |
          param_key = list_pattern % { key: key, ext: entry.first.to_s.split('_').last.capitalize, index: index + 1 }
          params[param_key] = normalize_val value
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
    Mws::Utils.uri_escape(value.respond_to?(:iso8601) ? value.iso8601 : value.to_s)
  end

end
