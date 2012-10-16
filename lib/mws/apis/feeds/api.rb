class Mws::Apis::Feeds::Api

  def initialize(connection, defaults={})
    @connection = connection
    defaults[:version] ||= '2009-01-01'
    @defaults = defaults
    @serializer = Mws::Serializer.new
  end

  def get(id)
    node = @connection.get('/', { feed_submission_id: id }, @defaults.merge(
      action: 'GetFeedSubmissionResult',
      xpath: 'AmazonEnvelope/Message'
    ))
    Mws::Apis::Feeds::SubmissionResult.from_xml node
  end

  def submit(body, params)
    params[:feed_type] = Mws::Apis::Feeds::Feed::Type.for(params[:feed_type]).val
    doc = @connection.post('/', params, body, @defaults.merge( action: 'SubmitFeed'))
    Mws::Apis::Feeds::SubmissionInfo.from_xml doc.xpath('FeedSubmissionInfo').first
  end

  def cancel(options={})

  end

  def list(params={})
    params[:feed_submission_id] ||= params.delete(:ids) || [ params.delete(:id) ].flatten.compact
    doc = @connection.get('/', params, @defaults.merge(action: 'GetFeedSubmissionList'))
    doc.xpath('FeedSubmissionInfo').map do | node |
      Mws::Apis::Feeds::SubmissionInfo.from_xml node
    end
  end

  def count()
    @connection.get('/', {}, @defaults.merge(action: 'GetFeedSubmissionCount')).xpath('Count').first.text.to_i
  end

end