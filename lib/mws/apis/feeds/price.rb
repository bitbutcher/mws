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
      amount = '%.2f' % @amount
      if parent
        parent.send(name, amount, currency: @currency)
        parent.to_xml
      else
        Nokogiri::XML::Builder.new do | xml |
          xml.send(name, amount, currency: @currency)
        end.to_xml
      end
    end

  end

end