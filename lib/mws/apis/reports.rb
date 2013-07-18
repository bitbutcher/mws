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

  def get(params={})
    #params[:markets] ||= [ params.delete(:markets) || params.delete(:market) || @param_defaults[:market] ].flatten.compact
    options = @option_defaults.merge action: 'GetReport'

    doc = @connection.get "/", params, options

    doc.gsub! /\r\n?/, "\n"

    begin
      parsed_report = doc.split("\n").map { |line| CSV.parse_line(line, col_sep: "\t") }
    rescue CSV::MalformedCSVError
      puts "failed to parse report line"
    end

    header = parsed_report.shift
    parsed_report.map { |item| Hash[header.zip(item)] }
  end

end
