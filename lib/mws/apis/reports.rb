class Mws::Apis::Reports

  require "csv"

  def initialize(connection, overrides={})
    @connection = connection
    @param_defaults = {
        market: 'ATVPDKIKX0DER'
    }.merge overrides
    @option_defaults = {
        version: '2009-01-01'
    }
  end

  def request_report(params={})
    options = @option_defaults.merge action: 'RequestReport'
    params.merge! report_type: "_GET_FLAT_FILE_OPEN_LISTINGS_DATA_"
    doc = @connection.get("/", params, options)
    report_request_id = doc.xpath("/RequestReportResponse/RequestReportResult/ReportRequestInfo[1]/ReportRequestId").text
  end

  def get_report_request(report_request_id, params={})
    options = @option_defaults.merge action: 'GetReportRequestList'
    params.merge! :"report_request_id_list.id.1" => report_request_id
    doc = @connection.get "/", params, options
    request_info = doc.xpath("/GetReportRequestListResponse/GetReportRequestListResult/ReportRequestInfo[1]").first
    status = request_info.xpath("ReportProcessingStatus").text
    report_id = request_info.xpath("GeneratedReportId").text
    (status == "_DONE_ ") ? report_id : nil
  end

  # Reports / GetReport Action, required parameter: report_id
  # Get and parse a formerly generated _GET_FLAT_FILE_OPEN_LISTINGS_DATA_ report result
  def get_report(params={})
    options = @option_defaults.merge action: 'GetReport'
    lines = @connection.get "/", params, options
    parsed_report = parse_report(lines)
    convert_to_hash(parsed_report)
  end

  private

  def parse_report(lines)
    lines.gsub! /\r\n?/, " \ n "
    parsed_report = lines.split(" \ n ").map { |line| CSV.parse_line(line, col_sep: " \ t ") }
    parsed_report
  end

  def convert_to_hash(parsed_report)
    header = parsed_report.shift
    parsed_report.map { |item| Hash[header.zip(item)] }
  end

end
