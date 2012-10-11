class Mws::Apis::Orders

  def initialize(connection, overrides={})
    @connection = connection
    @param_defaults = {
      market: 'ATVPDKIKX0DER'
    }.merge overrides

    @option_defaults = {
      version: '2011-01-01',
      list_pattern: '%{key}.%{ext}.%<index>d'
    }
  end

  def list(params={})
    params[:markets] ||= [ params.delete(:markets) || params.delete(:market) || @param_defaults[:market] ].flatten.compact
    options = @option_defaults.merge action: 'ListOrders'
    doc = @connection.get "/Orders/#{options[:version]}", params, options
    doc.xpath('Orders/Order').map do | node |
      'Someday this will be an Order'
    end
  end

end
