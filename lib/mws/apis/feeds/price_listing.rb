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
        @min.to_xml 'MAP', xml if @min
        @sale.to_xml 'Sale', xml if @sale
      end
    end

    private

    def validate
      if @min
        unless @min.amount < @base.amount
          raise Mws::Errors::ValidationError, "'Base Price' must be greater than 'Minimum Advertised Price'."
        end
        if @sale and @sale.price.amount <= @min.amount
          raise Mws::Errors::ValidationError, "'Sale Price' must be greater than 'Minimum Advertised Price'."
        end
      end
    end

  end

end