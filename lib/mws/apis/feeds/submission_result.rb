class Mws::Apis::Feeds::SubmissionResult

  private :initialize

  private_class_method :new

  Status = Mws::Enum.for complete: 'Complete', processing: 'Processing', rejected: 'Rejected'

  MessageCountType = Mws::Enum.for success: 'MessagesSuccessful', error: 'MessagesWithError', warning: 'MessagesWithWarning'

  MessageResultCode = Mws::Enum.for error: 'Error', warning: 'Warning'

  attr_reader :message_id, :transaction_id, :status, :message_results
  
  def initialize(node)
    @transaction_id = node.xpath('ProcessingReport/DocumentTransactionID').first.text.to_s
    @status = Status.for(node.xpath('ProcessingReport/StatusCode').first.text).sym
    @message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesProcessed').first.text.to_i
    
    @message_counts = {}
    [MessageCountType.SUCCESS, MessageCountType.ERROR, MessageCountType.WARNING].each do | type |
      @message_counts[type.sym] = node.xpath("ProcessingReport/ProcessingSummary/#{type.val}").first.text.to_i
    end
    @message_results = {}
    node.xpath('ProcessingReport/Result').each do | result_node |
      result = MessageResult.from_xml(result_node)
      @message_results[result.id] = result 
    end
  end

  def self.from_xml(node)
    new node
  end

  def ==(another)
    @transaction_id == another.transaction_id
  end

  def message_count(type=nil)
    type.nil? ? @message_count : @message_counts[type]
  end

  class MessageResult

    private :initialize

    private_class_method :new


    attr_accessor :id, :result, :result_code, :result_description, :additional_info

    def initialize(node)
      @id = node.xpath('MessageID').first.text.to_s
      @result = MessageResultCode.for(node.xpath('ResultCode').first.text.to_s).sym
      @result_code = node.xpath('ResultMessageCode').first.text.to_i
      @result_description = node.xpath('ResultDescription').first.text.to_s
      node.xpath('AdditionalInfo').each do | info |
        @additional_info = Mws::Serializer.new.hash_for(info, 'additional_info') 
      end
    end

    def self.from_xml(node)
      new node
    end

  end
end