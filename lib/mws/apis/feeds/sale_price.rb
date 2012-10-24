require 'nokogiri'

module Mws::Apis::Feeds

  class SalePrice

    attr_reader :price, :from, :to

    def initialize(price, from, to)
      @price = price
      @from = from
      @to = to
    end

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      @price == other.price and @from == other.from and @to == other.to
    end

    def to_xml(name='Sale', parent=nil)
      Mws::Serializer.tree name, parent do |xml|
        xml.send 'StartDate', @from.iso8601
        xml.send 'EndDate', @to.iso8601
        price.to_xml 'SalePrice', xml
      end
    end

  end

end