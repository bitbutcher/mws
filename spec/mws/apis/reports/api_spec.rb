require 'spec_helper'

module Mws::Apis::Reports

  describe Api do

    let(:connection) do
      Mws::Connection.new(
          merchant: 'GSWCJ4UBA31UTJ',
          access: 'AYQAKIAJSCWMLYXAQ6K3',
          secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
      )
    end

    let(:reports_api) do
      connection.reports
    end

    it "should return generated report id for a report with DONE status" do
      response_xml_body = <<END
<?xml version="1.0"?>
<GetReportRequestListResponse xmlns="http://mws.amazonaws.com/doc/2009-01-01/">
<GetReportRequestListResult>
  <NextToken>
  </NextToken>
  <HasNext>false</HasNext>
  <ReportRequestInfo>
    <ReportRequestId>7580976354</ReportRequestId>
    <ReportType>_GET_FLAT_FILE_OPEN_LISTINGS_DATA_</ReportType>
    <StartDate>2013-07-20T11:19:01+00:00</StartDate>
    <EndDate>2013-07-20T11:19:01+00:00</EndDate>
    <Scheduled>false</Scheduled>
    <SubmittedDate>2013-07-20T11:19:01+00:00</SubmittedDate>
    <ReportProcessingStatus>_DONE_</ReportProcessingStatus>
    <GeneratedReportId>11743408783</GeneratedReportId>
    <StartedProcessingDate>2013-07-20T11:27:42+00:00</StartedProcessingDate>
    <CompletedProcessingDate>2013-07-20T11:28:03+00:00</CompletedProcessingDate>
  </ReportRequestInfo>
</GetReportRequestListResult>
<ResponseMetadata>
  <RequestId>1b435755-d127-413e-9dd1-5c2f54cea33b</RequestId>
</ResponseMetadata>
</GetReportRequestListResponse>"
END
      connection.should_receive(:response_for).and_return { response_xml_body }
      reports_api.get_report_request("7580976354").should eq "11743408783"
    end

    it "should return nil for an uncompleted report" do
      response_xml_body = <<END
<?xml version="1.0"?>
<GetReportRequestListResponse xmlns="http://mws.amazonaws.com/doc/2009-01-01/">
<GetReportRequestListResult>
  <NextToken>
  </NextToken>
  <HasNext>false</HasNext>
  <ReportRequestInfo>
    <ReportRequestId>7589329190</ReportRequestId>
    <ReportType>_GET_FLAT_FILE_OPEN_LISTINGS_DATA_</ReportType>
    <StartDate>2013-07-21T18:10:28+00:00</StartDate>
    <EndDate>2013-07-21T18:10:28+00:00</EndDate>
    <Scheduled>false</Scheduled>
    <SubmittedDate>2013-07-21T18:10:28+00:00</SubmittedDate>
    <ReportProcessingStatus>_SUBMITTED_</ReportProcessingStatus>
  </ReportRequestInfo>
</GetReportRequestListResult>
<ResponseMetadata>
  <RequestId>96241497-20bd-4edc-90f0-4e9dda39c340</RequestId>
</ResponseMetadata>
</GetReportRequestListResponse>
END
      connection.should_receive(:response_for).and_return { response_xml_body }
      reports_api.get_report_request("7589329190").should be nil
    end

    it "should return reports count" do
      response_xml_body = <<END
<?xml version="1.0"?>
<GetReportCountResponse xmlns="http://mws.amazonaws.com/doc/2009-01-01/">
<GetReportCountResult>
  <Count>7</Count>
</GetReportCountResult>
<ResponseMetadata>
  <RequestId>87a113eb-18a8-4c46-874c-e6d740f750a8</RequestId>
</ResponseMetadata>
</GetReportCountResponse>
END
      connection.should_receive(:response_for).and_return { response_xml_body }
      reports_api.get_report_count.should be 7
    end


  end

end