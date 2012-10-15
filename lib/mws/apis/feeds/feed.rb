class Mws::Apis::Feeds::Feed

  attr_accessor :merchant_id, :message_type, :purge_and_replace, :messages

  def initialize(options={}, &block)
    @merchant = options[:merchant]
    @message_type = options[:message_type]
    @purge_and_replace = options[:purge_and_replace] || false

    @messages = []

    instance_eval &block if block_given?
  end

  def xml_for
    builder = Nokogiri::XML::Builder.new do | builder |
      builder.AmazonEnvelope('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'amznenvelope.xsd') {
        builder.Header {
          builder.DocumentVersion '1.01'
          builder.MerchantIdentifier @merchant
        }
        builder.MessageType @message_type
        builder.PurgeAndReplace @purge_and_replace
        @messages.each do | message |
          message.xml_for builder
        end
      }
    end
    builder.to_xml
  end 

  def message(operation_type, &body_builder)
    @messages << Message.new(@messages.length + 1, operation_type, body_builder)
  end

  class Message
    attr_accessor :id, :operation_type, :body_builder

    def initialize(id, operation_type, body_builder)
      @id = id
      @operation_type = operation_type
      @body_builder = body_builder
    end

    def xml_for(builder)
      builder.Message {
        builder.MessageID @id
        builder.OperationType @operation_type
        @body_builder.call builder
      }
    end
  end

end