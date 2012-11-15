require 'spec_helper'
require 'nokogiri'

module Mws::Apis::Feeds

  describe Transaction do 

    let(:submission_info) do
      SubmissionInfo.from_xml(
        Nokogiri::XML::Builder.new do
          FeedSubmissionInfo {
            FeedSubmissionId 5868304010
            FeedType '_POST_PRODUCT_DATA_'
            SubmittedDate '2012-10-16T21:19:08+00:00'
            FeedProcessingStatus '_SUBMITTED_'
          }
        end.doc.root
      )
    end
    
    describe '.new' do

      it 'should be able to create a transaction with no items' do
        transaction = Transaction.new submission_info
        transaction.id.should == "5868304010"
        transaction.status.should == SubmissionInfo::Status.SUBMITTED.sym
        transaction.type.should == Feed::Type.PRODUCT.sym
        transaction.submitted.should == Time.parse('2012-10-16T21:19:08+00:00')
        transaction.items.should be_empty
      end

      it 'should be able to create a transaction with items' do
        transaction = Transaction.new submission_info do
          item 1, '12345678', :update
          item 2, '87654321', :update, :main
          item 3, '87654321', :delete, :other
        end

        transaction.items.length.should == 3

        item = transaction.items[0]
        item.id.should == 1
        item.sku.should == '12345678'
        item.operation.should == :update
        item.qualifier.should be_nil

        item = transaction.items[1]
        item.id.should == 2
        item.sku.should == '87654321'
        item.operation.should == :update
        item.qualifier.should == :main

        item = transaction.items[2]
        item.id.should == 3
        item.sku.should == '87654321'
        item.operation.should == :delete
        item.qualifier.should == :other
      end

    end

  end

end