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

  # Reports / GetReport Action, required parameter: report_id
  # Get and parse a formerly generated _GET_FLAT_FILE_OPEN_LISTINGS_DATA_ report result
  def get(params={})
    options = @option_defaults.merge action: 'GetReport'
    lines = @connection.get "/", params, options
    parsed_report = parse_report(lines)
    convert_to_hash(parsed_report)
  end

  def parse_report(lines)
    lines.gsub! /\r\n?/, "\n"
    parsed_report = lines.split("\n").map { |line| CSV.parse_line(line, col_sep: "\t") }
    parsed_report
  end

  def convert_to_hash(parsed_report)
    header = parsed_report.shift
    parsed_report.map { |item| Hash[header.zip(item)] }
  end

end
