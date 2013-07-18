require 'spec_helper'

module Mws::Apis::Feeds

  describe Feed do

    let(:merchant) { 'GSWCJ4UBA31UTJ' }
    let(:message_type) { :image }

    context '.new' do

      it 'should require a merchant identifier' do
        expect { Feed.new(nil, message_type) }.to raise_error Mws::Errors::ValidationError,
          'Merchant identifier is required.'
      end

      it 'should require a valid message type' do
        expect { Feed.new(merchant, nil) }.to raise_error Mws::Errors::ValidationError,
          'A valid message type is required.'
      end

      it 'shoud default purge and replace to false' do
        Feed.new(merchant, message_type).purge_and_replace.should be false
      end

      it 'should accept overrides to purge and replace' do
        Feed.new(merchant, message_type, true).purge_and_replace.should be true
      end

      it 'should accept a block to append messages to the feed' do
        feed = Feed.new(merchant, message_type) do
          message ImageListing.new('1', 'http://foo.com/bar.jpg'), :delete
          message ImageListing.new('1', 'http://bar.com/foo.jpg')
        end
        feed.messages.size.should == 2
        first = feed.messages.first
        first.id.should == 1
        first.type.should == :image
        first.operation_type.should == :delete
        first.resource.should == ImageListing.new('1', 'http://foo.com/bar.jpg')
        second = feed.messages.last
        second.id.should == 2
        second.type.should == :image
        second.operation_type.should == :update
        second.resource.should == ImageListing.new('1', 'http://bar.com/foo.jpg')
      end

    end

    context '#to_xml' do

      it 'shoud properly serialize to xml' do
        expected = Nokogiri::XML::Builder.new {
          AmazonEnvelope('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:noNamespaceSchemaLocation' => 'amznenvelope.xsd') {
            Header {
              DocumentVersion '1.01'
              MerchantIdentifier 'GSWCJ4UBA31UTJ'
            }
            MessageType 'ProductImage'
            PurgeAndReplace false
            Message {
              MessageID 1
              OperationType 'Delete'
              ProductImage {
                SKU 1
                ImageType 'Main'
                ImageLocation 'http://foo.com/bar.jpg'
              }
            }
            Message {
              MessageID 2
              OperationType 'Update'
              ProductImage {
                SKU 1
                ImageType 'Main'
                ImageLocation 'http://bar.com/foo.jpg'
              }
            }
          }
        }.to_xml
        actual = Feed.new(merchant, message_type) do
          message ImageListing.new('1', 'http://foo.com/bar.jpg'), :delete
          message ImageListing.new('1', 'http://bar.com/foo.jpg')
        end.to_xml
        actual.should == expected
      end

    end

  end

end