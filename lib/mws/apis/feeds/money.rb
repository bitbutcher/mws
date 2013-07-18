module Mws::Apis::Feeds

  class Money < Measurement

    Currency = Mws::Enum.for(
      usd: 'USD', 
      gbp: 'GBP', 
      eur: 'EUR', 
      jpy: 'JPY', 
      cad: 'CAD', 
      default: 'DEFAULT'
    )

    Unit = Currency

    def initialize(amount, currency=nil)
      raise Mws::Errors::ValidationError, "Invalid currency '#{currency}'" if currency and Currency.for(currency).nil?
      super amount, currency || :usd
    end

    def currency
      unit
    end

    def to_xml(name='Price', parent=nil)
      Mws::Serializer.leaf name, parent, '%.2f' % @amount, currency: @unit.val
    end

  end

end