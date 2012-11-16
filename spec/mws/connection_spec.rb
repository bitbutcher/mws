require 'spec_helper'

module Mws

  class Connection
    attr_reader :scheme, :host, :merchant, :access, :secret
    public :request, :response_for, :parse
  end

  describe Connection do

    let(:defaults) {
      {
        merchant: 'GSWCJ4UBA31UTJ',
        access: 'AYQAKIAJSCWMLYXAQ6K3', 
        secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
      }
    }

    let(:connection) {
      Connection.new(defaults)
    }

    context '.new' do

      it 'should default scheme to https' do
        connection.scheme.should == 'https'
      end

      it 'should accept a custom scheme' do
        Connection.new(defaults.merge(scheme: 'http')).scheme.should == 'http'
      end

      it 'should default host to mws.amazonservices.com' do
        connection.host.should == 'mws.amazonservices.com'
      end

      it 'should accept a custom host' do
        Connection.new(defaults.merge(host: 'mws.amazonservices.uk')).host.should == 'mws.amazonservices.uk'
      end

      it 'should require a merchant identifier' do
        expect {
          Connection.new(
            access: defaults[:access],
            secret: defaults[:secret]
          )
        }.to raise_error Mws::Errors::ValidationError, 'A merchant identifier must be specified.'
      end

      it 'should accept a merchant identifier' do
        connection.merchant.should == 'GSWCJ4UBA31UTJ'
      end

      it 'should require an access key' do
        expect { 
          Connection.new(
            merchant: defaults[:merchant], 
            secret: defaults[:secret]
          )
        }.to raise_error Mws::Errors::ValidationError, 'An access key must be specified.'
      end

      it 'should accept an access key' do
        connection.access.should == 'AYQAKIAJSCWMLYXAQ6K3'
      end

      it 'should require a secret key' do
        expect { 
          Connection.new(
            merchant: defaults[:merchant],
            access: defaults[:access]
          )
        }.to raise_error Mws::Errors::ValidationError, 'A secret key must be specified.'
      end

      it 'should accept a secret key' do
        connection.secret.should == 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
      end

    end

    context '#get' do

      it 'should appropriately delegate to #request' do
        connection.should_receive(:request).with(:get, '/foo', { market: 'ATVPDKIKX0DER' }, nil, { version: 1 })
        connection.get('/foo', { market: 'ATVPDKIKX0DER' }, { version: 1 })
      end

    end

    context '#post' do

      it 'should appropriately delegate to #request' do
        connection.should_receive(:request).with(:post, '/foo', { market: 'ATVPDKIKX0DER' }, 'test_body', { version: 1 })
        connection.post('/foo', { market: 'ATVPDKIKX0DER' }, 'test_body', { version: 1 })
      end

    end

    context '#request' do

      it 'should construct a query, signer and make the request' do
        Query.should_receive(:new).with(
          action: nil, 
          version: nil, 
          merchant: 'GSWCJ4UBA31UTJ', 
          access: 'AYQAKIAJSCWMLYXAQ6K3', 
          list_pattern: nil
        ).and_return('the_query')
        signer = double('signer')
        Signer.should_receive(:new).with(
          method: :get,
          host: 'mws.amazonservices.com',
          path: '/foo',
          secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
        ).and_return(signer)
        signer.should_receive(:sign).with('the_query').and_return('the_signed_query')
        connection.should_receive(:response_for).with(:get, '/foo', 'the_signed_query', nil).and_return('the_response')
        connection.should_receive(:parse).with('the_response', {})
        connection.request(:get, '/foo', {}, nil, {})
      end

      it 'should merge additional request parameters into the query' do
        connection = Connection.new(
          merchant: 'GSWCJ4UBA31UTJ',
          access: 'AYQAKIAJSCWMLYXAQ6K3',
          secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
        )
        Query.should_receive(:new).with(
          action: nil, 
          version: nil, 
          merchant: 'GSWCJ4UBA31UTJ', 
          access: 'AYQAKIAJSCWMLYXAQ6K3', 
          list_pattern: nil,
          foo: 'bar',
          baz: 'quk'
        ).and_return('the_query')
        signer = double('signer')
        Signer.should_receive(:new).with(
          method: :get,
          host: 'mws.amazonservices.com',
          path: '/foo',
          secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
        ).and_return(signer)
        signer.should_receive(:sign).with('the_query').and_return('the_signed_query')
        connection.should_receive(:response_for).with(:get, '/foo', 'the_signed_query', nil).and_return('the_response')
        connection.should_receive(:parse).with('the_response', {})
        connection.request(:get, '/foo', { foo: 'bar', baz: 'quk' }, nil, {})
      end

      it 'should accept overrides to action, version and list_pattern' do
        Query.should_receive(:new).with(
          action: 'SubmitFeed', 
          version: '2009-01-01', 
          merchant: 'GSWCJ4UBA31UTJ', 
          access: 'AYQAKIAJSCWMLYXAQ6K3', 
          list_pattern: 'a_list_pattern'
        ).and_return('the_query')
        signer = double('signer')
        Signer.should_receive(:new).with(
          method: :get,
          host: 'mws.amazonservices.com',
          path: '/foo',
          secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
        ).and_return(signer)
        signer.should_receive(:sign).with('the_query').and_return('the_signed_query')
        connection.should_receive(:response_for).with(:get, '/foo', 'the_signed_query', nil).and_return('the_response')
        connection.should_receive(:parse).with('the_response', { action: 'SubmitFeed', version: '2009-01-01' })
        connection.request(:get, '/foo', {}, nil, { action: 'SubmitFeed', version: '2009-01-01', list_pattern: 'a_list_pattern' })
      end

    end

    context '#parse' do

    end

  end

end