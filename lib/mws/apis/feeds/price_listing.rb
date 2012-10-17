require 'nokogiri'

module Mws::Apis::Feeds

  class PriceListing

    attr_reader :sku, :currency, :base, :sale, :min

    def initialize(sku, base, options={})
      @sku = sku
      @currency = options[:currency] || 'USD'
      @base = Price.new(base, @currency)
      @min = Price.new(options[:min], @currency) if options.include? :min
      on_sale(options[:sale][:amount], options[:sale][:from], options[:sale][:to]) if options.include? :sale
      validate
    end

    def on_sale(amount, from, to)
      @sale = SalePrice.new Price.new(amount, @currency), from, to
      validate
      self
    end

    def to_xml(name='Price', parent=nil)
      block = lambda { |xml| 
        xml.send 'SKU', @sku
        @base.to_xml 'StandardPrice', xml
        @min.to_xml('MAP', xml) if @min
        @sale.to_xml('Sale', xml) if @sale
      }
      if parent
        parent.send('Price', &block)
        parent.to_xml
      else
        Nokogiri::XML::Builder.new do | xml |
          xml.send('Price', &block)
        end.to_xml
      end
    end

    private

    def validate
      if @min
        raise "'Base Price' must be greater than 'Minimum Advertised Price'." unless @min.amount < @base.amount
        if @sale
          raise "'Sale Price' must be greater than 'Minimum Advertised Price'." unless @min.amount < @sale.price.amount
        end
      end
    end

  end

end