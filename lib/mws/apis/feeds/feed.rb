require 'nokogiri'

module Mws::Apis::Feeds

  class Feed

    Type = Mws::Enum.for(
      product: '_POST_PRODUCT_DATA_', 
      product_relationship: '_POST_PRODUCT_RELATIONSHIP_DATA_', 
      item: '_POST_ITEM_DATA_', 
      override: '_POST_PRODUCT_OVERRIDES_DATA_', 
      image: '_POST_PRODUCT_IMAGE_DATA_', 
      price: '_POST_PRODUCT_PRICING_DATA_', 
      inventory: '_POST_INVENTORY_AVAILABILITY_DATA_', 
      order_acknowledgement: '_POST_ORDER_ACKNOWLEDGEMENT_DATA_', 
      order_fufillment: '_POST_ORDER_FULFILLMENT_DATA_', 
      fulfillment_order_request: '_POST_FULFILLMENT_ORDER_REQUEST_DATA_', 
      fulfillment_order_cancellation: '_POST_FULFILLMENT_ORDER_CANCELLATION_REQUEST_DATA'
    )

    attr_reader :merchant, :purge_and_replace

    Mws::Enum.sym_reader self, :message_type

    def initialize(merchant, message_type, purge_and_replace=false, &block)
      @merchant = merchant
      raise Mws::Errors::ValidationError, 'Merchant identifier is required.' if @merchant.nil?
      @message_type = Message::Type.for(message_type)
      raise Mws::Errors::ValidationError, 'A valid message type is required.' if @message_type.nil?
      @purge_and_replace = purge_and_replace
      @messages = []
      Builder.new(self, @messages).instance_eval &block if block_given?
    end

    def messages
      @messages.dup
    end

    def to_xml
      Nokogiri::XML::Builder.new do | xml |
        xml.AmazonEnvelope('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'amznenvelope.xsd') {
          xml.Header {
            xml.DocumentVersion '1.01'
            xml.MerchantIdentifier @merchant
          }
          xml.MessageType @message_type.val
          xml.PurgeAndReplace @purge_and_replace
          @messages.each do | message |
            message.to_xml xml
          end
        }
      end.to_xml
    end

    class Builder

      def initialize(feed, messages)
        @feed = feed
        @messages = messages
      end

      def message(resource, operation_type=nil)
        (@messages << Message.new(@messages.length + 1, @feed.message_type, resource, operation_type)).last
      end

    end

    class Message

      Type = Mws::Enum.for(
        fufillment_center: 'FulfillmentCenter',
        inventory: 'Inventory', 
        listings: 'Listings', 
        order_acknowledgement: 'OrderAcknowledgement', 
        order_adjustment: 'OrderAdjustment', 
        order_fulfillment: 'OrderFulfillment', 
        override: 'Override', 
        price: 'Price',
        processing_report: 'ProcessingReport',
        product: 'Product',
        image: 'ProductImage',
        relationship: 'Relationship',
        settlement_report: 'SettlementReport'
      )

      OperationType = Mws::Enum.for(
        update: 'Update', 
        delete: 'Delete', 
        partial_update: 'PartialUpdate'
      )

      attr_reader :id, :resource

      Mws::Enum.sym_reader self, :type, :operation_type

      def initialize(id, type, resource, operation_type)
        @id = id
        @type = Type.for(type)
        @resource = resource
        @operation_type = OperationType.for(operation_type) || OperationType.UPDATE
      end

      def to_xml(parent)
        Mws::Serializer.tree 'Message', parent do | xml |
          xml.MessageID @id
          xml.OperationType @operation_type.val
          @resource.to_xml @type.val, xml
        end
      end
    end

  end

end