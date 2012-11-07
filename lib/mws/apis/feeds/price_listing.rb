require 'nokogiri'

module Mws::Apis::Feeds

  class PriceListing

    attr_reader :sku, :currency, :base, :sale, :min

    def initialize(sku, base, options={})
      @sku = sku
      @base = Money.new(base, options[:currency])
      @currency =  @base.currency
      @min = Money.new(options[:min], @currency) if options.include? :min
      on_sale(options[:sale][:amount], options[:sale][:from], options[:sale][:to]) if options.include? :sale
      validate
    end

    def on_sale(amount, from, to)
      @sale = SalePrice.new Money.new(amount, @currency), from, to
      validate
      self
    end

    def to_xml(name='Price', parent=nil)
      Mws::Serializer.tree name, parent do |xml| 
        xml.SKU @sku
        @base.to_xml 'StandardPrice', xml
        @min.to_xml('MAP', xml) if @min
        @sale.to_xml('Sale', xml) if @sale
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