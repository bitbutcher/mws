require 'nokogiri'

module Mws::Apis::Feeds

  class Price

    attr_reader :amount, :currency

    def initialize(amount, currency=nil)
      @amount = amount
      @currency = currency || 'USD'
    end

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      @amount == other.amount and @currency == other.currency
    end

    def to_xml(name='Price', parent=nil)
      Mws::Serializer.leaf name, parent, '%.2f' % @amount, currency: @currency
    end

  end

end