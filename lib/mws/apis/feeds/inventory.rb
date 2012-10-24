require 'ostruct'
require 'nokogiri'

module Mws::Apis::Feeds

  class Inventory

    FulfillmentType = Mws::Enum.for afn: 'AFN', mfn: 'MFN'

    attr_reader :sku, :available, :quantity, :lookup, :fulfillment, :restock

    def initialize(sku, options)
      @sku = sku
      @available = options[:available]
      @quantity = options[:quantity]
      @lookup = options[:lookup]
      @fulfillment = OpenStruct.new(
        center: options[:fulfillment_center],
        latency: options[:fulfillment_latency],
        type: options[:fulfillment_type]
      )
      @restock = options[:restock]
      validate
    end

    def to_xml(name='Inventory', parent=nil)
      Mws::Serializer.tree name, parent do |xml| 
        xml.SKU @sku
        xml.FulfillmentCenterID @fulfillment.center unless @fulfillment.center.nil?
        xml.Available @available unless @available.nil?
        xml.Quantity @quantity unless @quantity.nil?
        xml.Lookup @lookup unless @lookup.nil?
        xml.RestockDate @restock.iso8601 unless @restock.nil?
        xml.FulfillmentLatency @fulfillment.latency unless @fulfillment.latency.nil?
        xml.SwitchFulfillmentTo FulfillmentType.for(@fulfillment.type).val unless @fulfillment.type.nil?
      end
    end

    private

    def validate
      raise Mws::Errors::ValidationError.new('SKU is required.') if @sku.nil? or @sku.to_s.strip.empty?
      unless [ @available, @quantity, @lookup ].compact.size == 1
        raise Mws::Errors::ValidationError.new("One and only one of 'available', 'quantity' or 'lookup' must be specified.")
      end
      unless @available.nil? or [ true, false ].include? @available
        raise Mws::Errors::ValidationError.new('Available must be either true or false.')
      end
      unless @quantity.nil? or (@quantity.to_i == @quantity and @quantity >= 0)
        raise Mws::Errors::ValidationError.new('Quantity must be a whole number greater than or equal to zero.')
      end
      unless @lookup.nil? or [ true, false ].include? @lookup
        raise Mws::Errors::ValidationError.new('Lookup must be either true or false.')
      end
      unless @fulfillment.latency.nil? or (@fulfillment.latency.to_i == @fulfillment.latency and @fulfillment.latency > 0)
        raise Mws::Errors::ValidationError.new('Fulfillment latency must be a whole number greater than zero.')
      end
      if @fulfillment.type and FulfillmentType.for(@fulfillment.type).nil?
        raise Mws::Errors::ValidationError.new("Fulfillment type must be either 'AFN' or 'MFN'.")
      end 
      unless @restock.nil? or (@restock.respond_to? :iso8601 and Time.now < @restock)
        raise Mws::Errors::ValidationError.new('Restock date must be in the future.')
      end
    end

  end

end