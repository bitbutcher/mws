class Mws::Apis::Feeds

  def initialize(connection, defaults={})
    @connection = connection
    defaults[:version] ||= '2009-01-01'
    @defaults = defaults
  end

  def get(id)

  end

  def submit(body, options)

  end

  def cancel(options={})

  end

  def list(options={})
    options[:version] ||= @defaults[:version]
    options[:action] = 'GetFeedSubmissionList'
    doc = @connection.get('/', options, lambda { | key | 
      "List.#{key.split('_').last.capitalize}"
    })
    puts doc.to_xml
    doc.xpath('xmlns:FeedSubmissionInfo').map do | node |
      'Someday this will be an FeedSubmission'
    end
  end

  def count(options={})

  end

end
