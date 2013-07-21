class Mws::Apis::Reports::FlatFileOpenListingsData

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

  # Initiates a "flat file open listings data" report generation
  def request(params={})
    options = @option_defaults.merge action: 'RequestReport'
    params.merge! report_type: "_GET_FLAT_FILE_OPEN_LISTINGS_DATA_"
    doc = @connection.get("/", params, options)
    request_info = doc.xpath("/RequestReportResponse/RequestReportResult/ReportRequestInfo[1]").first
    status = request_info.xpath("ReportProcessingStatus").text
    status == "_SUBMITTED_" ? request_info.xpath("ReportRequestId").text : nil
  end

  # Gets and parses a formerly generated "flat file open listings data" report result
  # Required parameter: report_id which can be obtained by get_report_request method
  def get(report_id, params={})
    options = @option_defaults.merge action: 'GetReport'
    params.merge! :"report_id" => report_id
    lines = @connection.get "/", params, options
    parsed_report = parse_report(lines)
    convert_to_hash(parsed_report)
  end

  def parse_report(report_lines)
    report_lines.gsub! /\r\n?/, "\n"
    parsed_report = report_lines.split("\n").map { |line| CSV.parse_line(line, col_sep: "\t") }
    parsed_report
  end

  def convert_to_hash(parsed_report)
    header = parsed_report.shift
    parsed_report.map { |item| Hash[header.zip(item)] }
  end

end
