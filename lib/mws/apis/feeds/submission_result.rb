class Mws::Apis::Feeds::SubmissionResult

  attr_accessor :message_id, :transaction_id, :status_code, :processed_message_count, :successfull_message_count, :error_message_count, :warning_message_count

  def initialize
    yield self if block_given?
  end

  def self.from_xml(node)
    new do | result |
      result.message_id = node.xpath('MessageID').first.text.to_s
      result.transaction_id = node.xpath('ProcessingReport/DocumentTransactionID').first.text.to_s
      result.status_code = node.xpath('ProcessingReport/StatusCode').first.text.to_sym
      result.processed_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesProcessed').first.text.to_i
      result.successfull_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesSuccessful').first.text.to_i
      result.error_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesWithError').first.text.to_i
      result.warning_message_count = node.xpath('ProcessingReport/ProcessingSummary/MessagesWithWarning').first.text.to_i
    end
  end

  def ==(another)
    @transaction_id == another.transaction_id
  end
end