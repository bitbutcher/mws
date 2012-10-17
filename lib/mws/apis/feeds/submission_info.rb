class Mws::Apis::Feeds::SubmissionInfo
  
  private :initialize

  private_class_method :new

  Status = Mws::Enum.for done: '_DONE_', submitted: '_SUBMITTED_', in_progress: '_IN_PROGRESS_', cancelled: '_CANCELLED_'

  attr_accessor :id, :type, :status, :submitted, :started, :completed

  def initialize(node)
    @id = node.xpath('FeedSubmissionId').first.text.to_s
    @type = Mws::Apis::Feeds::Feed::Type.for(node.xpath('FeedType').first.text).sym
    @status = Status.for(node.xpath('FeedProcessingStatus').first.text).sym
    @submitted = Time.parse(node.xpath('SubmittedDate').first.text.to_s)
    node.xpath('StartedProcessingDate').each do | node |
      @started = Time.parse(node.text.to_s)  
    end
    node.xpath('CompletedProcessingDate').each do | node |
      @completed = Time.parse(node.text.to_s)
    end
  end

  def self.from_xml(node)
    new node
  end 

  def ==(another)
    @id == another.id
  end
end