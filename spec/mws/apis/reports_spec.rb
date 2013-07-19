# encoding: utf-8

require 'spec_helper'

module Mws::Apis

  describe Reports do

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

    it "should parse tab delimited lines correctly" do
      input = "sku	asin	price	quantity
GY-8YTI-6CDC	B007DCI0E6	47.00	2
II-4545-W3B6	B004UBTEIO	39.00	3"
      output = [["sku", "asin", "price", "quantity"], ["GY-8YTI-6CDC", "B007DCI0E6", "47.00", "2"], ["II-4545-W3B6", "B004UBTEIO", "39.00", "3"]]
      reports_api.parse_report(input).should eq output
    end

    it "should convert arrays to hash using header line as keys" do
      input = [["sku", "asin", "price", "quantity"], ["GY-8YTI-6CDC", "B007DCI0E6", "47.00", "2"], ["II-4545-W3B6", "B004UBTEIO", "39.00", "3"]]
      output = [{"sku"=>"GY-8YTI-6CDC", "asin"=>"B007DCI0E6", "price"=>"47.00", "quantity"=>"2"}, {"sku"=>"II-4545-W3B6", "asin"=>"B004UBTEIO", "price"=>"39.00", "quantity"=>"3"}]
      reports_api.convert_to_hash(input).should eq output
    end

  end

end