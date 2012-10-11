class Mws::Apis::Feeds

  def initialize(connection, defaults={})
    @connection = connection
    defaults[:version] ||= '2009-01-01'
    @defaults = defaults
  end

  def get(id)
    doc = @connection.get('/', { feed_submission_id: id }, @defaults.merge(
      action: 'GetFeedSubmissionResult',
      xpath: 'AmazonEnvelope/Message/ProcessingReport'
    ))
    doc.xpath('FeedSubmissionInfo').map do | node |
      
    end
  end

  def submit(body, params)
    doc = @connection.post('/', params, body, @defaults.merge( action: 'SubmitFeed'))
  end

  def cancel(options={})

  end

  def list(params={})
    doc = @connection.get('/', params, @defaults.merge(action: 'GetFeedSubmissionList'))
    doc.xpath('FeedSubmissionInfo').map do | node |
      'Someday this will be an FeedSubmission'
    end
  end

  def count()
    @connection.get('/', {}, @defaults.merge(action: 'GetFeedSubmissionCount')).xpath('Count').first.text.to_i
  end

end
