class Mws::Apis::Feeds

  def initialize(connection)
    @connection = connection
  end

  def list(options={})
    options[:version] ||= '2009-01-01'
    options[:action] = 'ListOrders'
    response = @connection.get(:orders, options)
    response['Orders'] || []
  end

end
