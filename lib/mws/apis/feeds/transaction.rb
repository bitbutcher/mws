module Mws::Apis::Feeds
	
	class Transaction

    attr_reader :id, :type, :status, :submitted, :items

    def initialize(submission_info, items=[], &item_builder)
      @id = submission_info.id
      @type = submission_info.type
      @status = submission_info.status
      @submitted = submission_info.submitted
      @items = items
      instance_eval &item_builder unless item_builder.nil?
    end

    private

    def item(id, sku, operation, qualifier=nil)
      @items << Item.new(id, sku, operation, qualifier)
    end

    class Item

      attr_reader :id, :sku, :operation, :qualifier

      def initialize(id, sku, operation, qualifier)
        @id = id
        @sku  = sku
        @operation = operation
        @qualifier = qualifier
      end

    end

  end

end