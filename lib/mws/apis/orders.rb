class Mws::Apis::Orders

  def initialize(connection)
    @connection = connection
  end

  def list(options={})
    options[:version] ||= '2011-01-01'
    options[:action] = 'ListOrders'
    doc = @connection.get(:orders, options)
    doc.find('mws:Orders/mws:Order').map do | node |
      'Someday this will be an Order'
    end
  end

end
