require 'spec_helper'

module Mws::Apis::Feeds

  class Api
    attr_reader :defaults
  end

  describe Api do

    let(:connection) do
      Mws::Connection.new(
        merchant: 'GSWCJ4UBA31UTJ',
        access: 'AYQAKIAJSCWMLYXAQ6K3', 
        secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
      )
    end

    let(:api) { Api.new(connection) }

    context '.new' do

      it 'should require connection' do
        expect { Api.new(nil) }.to raise_error Mws::Errors::ValidationError, 'A connection is required.'
      end

      it 'should default version to 2009-01-01' do
        api.defaults[:version].should == '2009-01-01'
      end

      it 'should initialize a products feed' do
        TargetedApi.as_null_object
        TargetedApi.should_receive(:new).with(anything, connection.merchant, :product)
        api = Api.new(connection)
        api.products.should_not be nil
      end

      it 'should initialize an images feed' do
        TargetedApi.as_null_object
        TargetedApi.should_receive(:new).with(anything, connection.merchant, :image)
        api = Api.new(connection)
        api.images.should_not be nil
      end

      it 'should initialize a prices feed' do
        TargetedApi.as_null_object
        TargetedApi.should_receive(:new).with(anything, connection.merchant, :price)
        api = Api.new(connection)
        api.prices.should_not be nil
      end

      it 'should initialize a shipping feed' do
        TargetedApi.as_null_object
        TargetedApi.should_receive(:new).with(anything, connection.merchant, :override)
        api = Api.new(connection)
        api.shipping.should_not be nil
      end

      it 'should initialize an inventory feed' do
        TargetedApi.as_null_object
        TargetedApi.should_receive(:new).with(anything, connection.merchant, :inventory)
        api = Api.new(connection)
        api.inventory.should_not be nil
      end

    end

    context '#get' do

      it 'should properly delegate to connection' do
        connection.should_receive(:get).with('/', { feed_submission_id: 1 }, { 
          version: '2009-01-01',
          action: 'GetFeedSubmissionResult',
          xpath: 'AmazonEnvelope/Message'
        }).and_return('a_node')
        SubmissionResult.should_receive(:from_xml).with('a_node')
        api.get(1)
      end

    end

    context '#submit' do

      it 'should properly delegate to connection' do
        response = double(:response)
        response.should_receive(:xpath).with('FeedSubmissionInfo').and_return(['a_result'])
        connection.should_receive(:post).with('/', { feed_type: '_POST_INVENTORY_AVAILABILITY_DATA_' }, 'a_body', {
          version: '2009-01-01',
          action: 'SubmitFeed'
        }).and_return(response)
        SubmissionInfo.should_receive(:from_xml).with('a_result')
        api.submit 'a_body', feed_type: :inventory
      end

    end

    context '#list' do

      it 'should handle a single submission id' do
        response = double(:response)
        response.should_receive(:xpath).with('FeedSubmissionInfo').and_return(['result_one'])
        connection.should_receive(:get).with('/', { feed_submission_id: [ 1 ] }, {
          version: '2009-01-01',
          action: 'GetFeedSubmissionList'
        }).and_return(response)
        SubmissionInfo.should_receive(:from_xml) { | node | node }.once
        api.list(id: 1).should == [ 'result_one' ]
      end

      it 'should handle a multiple submission ids' do
        response = double(:response)
        response.should_receive(:xpath).with('FeedSubmissionInfo').and_return([ 'result_one', 'result_two', 'result_three' ])
        connection.should_receive(:get).with('/', { feed_submission_id: [ 1, 2, 3 ] }, {
          version: '2009-01-01',
          action: 'GetFeedSubmissionList'
        }).and_return(response)
        SubmissionInfo.should_receive(:from_xml) { | node | node }.exactly(3).times
        api.list(ids: [ 1, 2, 3 ]).should == [ 'result_one', 'result_two', 'result_three' ]
      end

    end

    context '#count' do

      it 'should properly delegate to connection' do
        count = double(:count)
        count.should_receive(:text).and_return('5')
        response = double(:response)
        response.should_receive(:xpath).with('Count').and_return([ count ])
        connection.should_receive(:get).with('/', {}, {
          version: '2009-01-01',
          action: 'GetFeedSubmissionCount'
        }).and_return(response)
        api.count.should == 5
      end

    end

  end

  describe TargetedApi do

    let(:connection) do
      Mws::Connection.new(
        merchant: 'GSWCJ4UBA31UTJ',
        access: 'AYQAKIAJSCWMLYXAQ6K3', 
        secret: 'Ubzq/NskSrW4m5ncq53kddzBej7O7IE5Yx9drGrX'
      )
    end

    let(:api) { Api.new(connection) }

    context '#add' do

      it 'should properly delegate to #submit' do
        api.products.should_receive(:submit).with([ 'resource_one', 'resource_two' ], :update, true).and_return('a_result')
        api.products.add('resource_one', 'resource_two').should == 'a_result'
      end

    end

    context '#update' do

      it 'should properly delegate to #submit' do
        api.products.should_receive(:submit).with([ 'resource_one', 'resource_two' ], :update).and_return('a_result')
        api.products.update('resource_one', 'resource_two').should == 'a_result'
      end

    end

    context '#patch' do

      it 'should properly delegate to #submit for products' do
        api.products.should_receive(:submit).with([ 'resource_one', 'resource_two' ], :partial_update).and_return('a_result')
        api.products.patch('resource_one', 'resource_two').should == 'a_result'
      end

      it 'should not be supported for feeds other than products' do
        expect { api.images.patch('resource_one', 'resource_two') }.to raise_error 'Operation Type not supported.'
      end

    end

    context '#delete' do

      it 'should properly delegate to #submit' do
        api.products.should_receive(:submit).with([ 'resource_one', 'resource_two' ], :delete).and_return('a_result')
        api.products.delete('resource_one', 'resource_two').should == 'a_result'
      end

    end

    context '#submit' do

      it 'should properly construct the feed and delegate to feeds' do
        resource = double :resource
        resource.stub(:to_xml)
        resource.stub(:sku).and_return('a_sku')
        resource.stub(:operation_type).and_return(:update)
        feed_xml = Nokogiri::XML::Builder.new do
          AmazonEnvelope('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'amznenvelope.xsd') {
            Header {
              DocumentVersion '1.01'
              MerchantIdentifier 'GSWCJ4UBA31UTJ'
            }
            MessageType 'Product'
            PurgeAndReplace false
            Message {
              MessageID 1
              OperationType 'Update'
            }
          }
        end.doc.to_xml
        submission_info = double(:submission_info).as_null_object
        api.should_receive(:submit).with(feed_xml, feed_type: Feed::Type.PRODUCT, purge_and_replace: false).and_return(submission_info)
        tx = api.products.submit [ resource ], :update
        tx.items.size.should == 1
        item = tx.items.first
        item.id.should == 1
        item.sku.should == 'a_sku'
        item.operation.should == :update
        item.qualifier.should be nil
      end

    end

  end

end