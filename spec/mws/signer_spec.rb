require 'spec_helper'

module Mws

  class Signer
    attr_reader :verb, :host, :path, :secret
  end

  describe Signer do
    
    let(:query) { 'AWSAccessKeyId=Q6K3SCWMLYAKIAJXAAYQ&LastUpdatedAfter=2012-10-12T11%3A11%3A54-05%3A00&MarketplaceIdList.Id.1=ATVPDKIKX0DER&MarketplaceIdList.Id.2=KIKX0DERATVPD&SellerId=J4UBGSWCA31UTJ&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2012-10-12T15%3A14%3A52-05%3A00' }

    let(:signer) { Signer.new({}) }

    it 'should default verb to POST' do
      signer.verb.should == 'POST'
    end

    it 'should default host to mws.amazonservices.com' do
      signer.host.should == 'mws.amazonservices.com'
    end

    it 'should default path to /' do
      signer.path.should == '/'
    end

    it 'should accept overrides to verb via the method or verb options' do
      [ :method, :verb ].each do | key |
        Signer.new({key => 'get'}).verb.should == 'GET'
      end
    end

    it 'should accept overrides to host via the host option' do
      Signer.new(host: 'MWS.AmazonServices.DE').host.should == 'mws.amazonservices.de'
    end

    it 'should accept overrides to path via the path option' do
      Signer.new(path: '/Foo/Bar').path.should == '/Foo/Bar'
    end

    it 'should accept secret values via the secret option' do
      secret = '53kddzBej7O7I5Yx9drGrXEUbzq/NskSrW4m5ncq'
      Signer.new(secret: secret).secret.should == secret
    end

    it 'should correctly calculate a signature for the provided query and secret' do
      signer.signature(query, '53kddzBej7O7I5Yx9drGrXEUbzq/NskSrW4m5ncq').should == 'jsOaccLC2MUFSUh5Lz7DdSA1+2//98LnUNp/b8xFi+0='
    end

    it 'should correctly calculate a signature for the provided query and default secret' do
      Signer.new(secret: '53kddzBej7O7I5Yx9drGrXEUbzq/NskSrW4m5ncq').signature(query).should == 'jsOaccLC2MUFSUh5Lz7DdSA1+2//98LnUNp/b8xFi+0='
    end

    it 'should correclty sign the provided query and secret' do
      signature = URI.encode_www_form_component signer.signature(query, '53kddzBej7O7I5Yx9drGrXEUbzq/NskSrW4m5ncq')
      signer.sign(query, '53kddzBej7O7I5Yx9drGrXEUbzq/NskSrW4m5ncq').should == "#{query}&Signature=#{signature}"
    end

    it 'should correctly sign the provided query and default secret' do
      signer = Signer.new(secret: '53kddzBej7O7I5Yx9drGrXEUbzq/NskSrW4m5ncq')
      signature = URI.encode_www_form_component signer.signature(query)
      signer.sign(query).should == "#{query}&Signature=#{signature}"
    end

  end

end