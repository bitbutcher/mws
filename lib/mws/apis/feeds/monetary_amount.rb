require 'nokogiri'

module Mws::Apis::Feeds

  class MonetaryAmount

    Currency = Mws::Enum.for usd: 'USD', gbp: 'GBP', eur: 'EUR', jpy: 'JPY', cad: 'CAD', default: 'DEFAULT'

    attr_reader :amount, :currency

    def initialize(amount, currency=nil)
      @amount = amount
      raise "Invalid currency type '#{currency}'" if !currency.nil? and Currency.for(currency).nil?
      @currency = currency || :usd
    end

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      @amount == other.amount and @currency == other.currency
    end

    def to_xml(name='Price', parent=nil)
      Mws::Serializer.leaf name, parent, '%.2f' % @amount, currency: Currency.for(@currency).val
    end

  end

end