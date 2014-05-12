module Mws::Apis::Reports

  class Api

    attr_reader :flat_file_open_listings_data

    def initialize(connection, overrides={})
      raise Mws::Errors::ValidationError, 'A connection is required.' if connection.nil?
      @connection = connection
      @param_defaults = {
          market: 'ATVPDKIKX0DER'
      }.merge overrides
      @option_defaults = {
          version: '2009-01-01'
      }

      @flat_file_open_listings_data = FlatFileOpenListingsData.new(connection)
    end

    # Gets status of a formerly initiated report generation, required parameter: report_request_id
    def get_report_request(report_request_id, params={})
      options = @option_defaults.merge action: 'GetReportRequestList'
      params.merge! :"report_request_id_list.id.1" => report_request_id
      doc = @connection.get "/", params, options
      request_info = doc.xpath("/GetReportRequestListResponse/GetReportRequestListResult/ReportRequestInfo[1]").first
      status = request_info.xpath("ReportProcessingStatus").text
      report_id = request_info.xpath("GeneratedReportId").text
      (status == "_DONE_") ? report_id : nil
    end

    def get_report_count(params={})
      options = @option_defaults.merge action: 'GetReportCount'
      doc = @connection.get "/", params, options
      count = doc.xpath("/GetReportCountResponse/GetReportCountResult/Count[1]").text.to_i
    end

  end

end
