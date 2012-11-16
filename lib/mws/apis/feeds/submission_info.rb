module Mws::Apis::Feeds

  class SubmissionInfo
    
    private :initialize

    private_class_method :new

    Status = Mws::Enum.for(
      done: '_DONE_', 
      submitted: '_SUBMITTED_', 
      in_progress: '_IN_PROGRESS_', 
      cancelled: '_CANCELLED_'
    )

    attr_accessor :id, :submitted, :started, :completed

    Mws::Enum.sym_reader self, :type, :status

    def initialize(node)
      @id = node.xpath('FeedSubmissionId').first.text.to_s
      @type = Feed::Type.for(node.xpath('FeedType').first.text)
      @status = Status.for(node.xpath('FeedProcessingStatus').first.text)
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

    def ==(other)
      return true if equal? other
      return false unless other.class == self.class
      id == other.id
    end

  end

end