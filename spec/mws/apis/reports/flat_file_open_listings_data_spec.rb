require 'spec_helper'

module Mws::Apis::Reports

  describe FlatFileOpenListingsData do

    let(:connection) do
      Mws::Connection.new(
          merchant: 'GSWCJ4UBA31UTJ',
          access: 'AYQAKIAJSCWMLYXAQ6K3',
          secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
      )
    end

    let(:reports_flat_file_open_listings_data_api) do
      connection.reports.flat_file_open_listings_data
    end

    it "should request a report generation" do
      response_xml_body = <<END
<?xml version="1.0"?>
<RequestReportResponse xmlns="http://mws.amazonaws.com/doc/2009-01-01/">
<RequestReportResult>
  <ReportRequestInfo>
    <ReportRequestId>7589269186</ReportRequestId>
    <ReportType>_GET_FLAT_FILE_OPEN_LISTINGS_DATA_</ReportType>
    <StartDate>2013-07-21T18:00:06+00:00</StartDate>
    <EndDate>2013-07-21T18:00:06+00:00</EndDate>
    <Scheduled>false</Scheduled>
    <SubmittedDate>2013-07-21T18:00:06+00:00</SubmittedDate>
    <ReportProcessingStatus>_SUBMITTED_</ReportProcessingStatus>
  </ReportRequestInfo>
</RequestReportResult>
<ResponseMetadata>
  <RequestId>5e529e1b-c0fa-438d-a602-704d5ab80728</RequestId>
</ResponseMetadata>
</RequestReportResponse>
END
      connection.should_receive(:response_for).and_return { response_xml_body }
      reports_flat_file_open_listings_data_api.request.should eq "7589269186"
    end

    it "should parse tab delimited lines of a report result" do
      input = "sku	asin	price	quantity
GY-8YTI-6CDC	B007DCI0E6	47.00	2
II-4545-W3B6	B004UBTEIO	39.00	3"
      output = [["sku", "asin", "price", "quantity"], ["GY-8YTI-6CDC", "B007DCI0E6", "47.00", "2"], ["II-4545-W3B6", "B004UBTEIO", "39.00", "3"]]
      reports_flat_file_open_listings_data_api.parse_report(input).should eq output
    end

    it "should convert report arrays to hash using the header line as keys" do
      input = [["sku", "asin", "price", "quantity"], ["GY-8YTI-6CDC", "B007DCI0E6", "47.00", "2"], ["II-4545-W3B6", "B004UBTEIO", "39.00", "3"]]
      output = [{"sku" => "GY-8YTI-6CDC", "asin" => "B007DCI0E6", "price" => "47.00", "quantity" => "2"}, {"sku" => "II-4545-W3B6", "asin" => "B004UBTEIO", "price" => "39.00", "quantity" => "3"}]
      reports_flat_file_open_listings_data_api.convert_to_hash(input).should eq output
    end

  end

end