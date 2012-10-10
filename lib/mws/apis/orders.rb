class Mws::Apis::Orders

  def initialize(connection, defaults={})
    @connection = connection
    defaults[:version] ||= '2011-01-01'
    defaults[:market] ||= 'ATVPDKIKX0DER'
    @defaults = defaults
  end

  def list(options={})
    options[:version] ||= @defaults[:version]
    options[:market] ||= @defaults[:market]
    options[:action] = 'ListOrders'
    doc = @connection.get("/Orders/#{options[:version]}", options, lambda { | key | 
      ".#{key.split('_').last.capitalize}"
    })
    puts doc.to_xml
    doc.xpath('xmlns:Orders/xmlns:Order').map do | node |
      'Someday this will be an Order'
    end
  end

end
