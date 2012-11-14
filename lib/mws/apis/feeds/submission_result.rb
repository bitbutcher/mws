module Mws::Apis::Feeds

  class SubmissionResult

    private :initialize

    private_class_method :new

    Status = Mws::Enum.for(
      complete: 'Complete', 
      processing: 'Processing', 
      rejected: 'Rejected'
    )

    attr_reader :transaction_id, :messages_processed

    Mws::Enum.sym_reader self, :status
    
    def initialize(node)
      @transaction_id = node.xpath('ProcessingReport/DocumentTransactionID').first.text.to_s
      @status = Status.for(node.xpath('ProcessingReport/StatusCode').first.text)
      @messages_processed = node.xpath('ProcessingReport/ProcessingSummary/MessagesProcessed').first.text.to_i
      
      @counts = {}
      [ Response::Type.SUCCESS, Response::Type.ERROR, Response::Type.WARNING ].each do | type |
        @counts[type.sym] = node.xpath("ProcessingReport/ProcessingSummary/#{type.val.first}").first.text.to_i
      end
      @responses = {}
      node.xpath('ProcessingReport/Result').each do | result_node |
        response = Response.from_xml(result_node)
        @responses[response.id.to_sym] = response 
      end
    end

    def self.from_xml(node)
      new node
    end

    def ==(another)
      @transaction_id == another.transaction_id
    end

    def count_for(type)
      @counts[Response::Type.for(type).sym]
    end

    def response_for(message_id)
      @responses[message_id.to_s.to_sym]
    end

    class Response

      Type = Mws::Enum.for(
        success: [ 'MessagesSuccessful' ],
        error: [ 'MessagesWithError', 'Error' ], 
        warning: [ 'MessagesWithWarning', 'Warning' ]
      )

      private :initialize

      private_class_method :new

      attr_reader :id, :code, :description, :additional_info

      Mws::Enum.sym_reader self, :type

      def initialize(node)
        @id = node.xpath('MessageID').first.text.to_s
        @type = Type.for(node.xpath('ResultCode').first.text.to_s)
        @code = node.xpath('ResultMessageCode').first.text.to_i
        @description = node.xpath('ResultDescription').first.text.to_s
        node.xpath('AdditionalInfo').each do | info |
          @additional_info = Mws::Serializer.new.hash_for(info, 'additional_info') 
        end
      end

      def self.from_xml(node)
        new node
      end

    end

  end

end