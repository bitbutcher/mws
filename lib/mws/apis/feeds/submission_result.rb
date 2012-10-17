class Mws::Apis::Feeds::SubmissionResult

  StatusCode = Mws::Enum.for complete: 'Complete', processing: 'Processing', rejected: 'Rejected'

  attr_accessor :message_id, :transaction_id, :status_code, :processed_message_count, :successfull_message_count, :error_message_count, :warning_message_count
  attr_accessor :message_results

  def initialize
    @message_results = []

    yield self if block_given?
  end

  def self.from_xml(node)
    new do | result |
      result.message_id = node.xpath('MessageID').first.text.to_s
      result.transaction_id = node.xpath('ProcessingReport/DocumentTransactionID').first.text.to_s
      result.status_code = StatusCode.for(node.xpath('ProcessingReport/StatusCode').first.text).sym
      result.processed_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesProcessed').first.text.to_i
      result.successfull_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesSuccessful').first.text.to_i
      result.error_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesWithError').first.text.to_i
      result.warning_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesWithWarning').first.text.to_i

      node.xpath('ProcessingReport/Result').each do | result_node |
        result.message_results << MessageResult.from_xml(result_node)
      end
    end
  end

  def ==(another)
    @transaction_id == another.transaction_id
  end

  class MessageResult

    attr_accessor :message_id, :result_code, :result_message_code, :result_description, :additional_info

    def initialize
      yield self if block_given?
    end

    def self.from_xml(node)
      new do | message |
        message.message_id = node.xpath('MessageID').first.text.to_s
        message.result_code = node.xpath('ResultCode').first.text.to_s
        message.result_message_code = node.xpath('ResultMessageCode').first.text.to_i
        message.result_description = node.xpath('ResultDescription').first.text.to_s
        node.xpath('AdditionalInfo').each do | info |
          message.additional_info = Mws::Serializer.new.hash_for(info, 'additional_info') 
        end
      end
    end

  end
end