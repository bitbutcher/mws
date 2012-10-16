class Mws::Apis::Feeds::SubmissionInfo
  
  Status = Mws::Enum.for done: '_DONE_', submitted: '_SUBMITTED_', in_progress: '_IN_PROGRESS_', cancelled: '_CANCELLED_'

  attr_accessor :id, :feed_type, :status, :submitted_timestamp, :started_timestamp, :completed_timestamp 

  def initialize
    yield self if block_given?
  end

  def self.from_xml(node)
    new do | info |
      info.id = node.xpath('FeedSubmissionId').first.text.to_s
      info.feed_type = node.xpath('FeedType').first.text.to_sym
      info.status = Status.for(node.xpath('FeedProcessingStatus').first.text).sym
      info.submitted_timestamp = Time.parse(node.xpath('SubmittedDate').first.text.to_s)
      node.xpath('StartedProcessingDate').each do | node |
        info.started_timestamp = Time.parse(node.text.to_s)  
      end
      node.xpath('CompletedProcessingDate').each do | node |
        info.completed_timestamp = Time.parse(node.text.to_s)
      end
    end
  end 

  def ==(another)
    @id == another.id
  end
end