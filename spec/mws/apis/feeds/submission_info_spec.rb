require 'spec_helper'
require 'nokogiri'

module Mws::Apis::Feeds

  describe SubmissionInfo do 

    let(:submitted_node) do
      Nokogiri::XML::Builder.new do
        FeedSubmissionInfo {
          FeedSubmissionId 5868304010
          FeedType '_POST_PRODUCT_DATA_'
          SubmittedDate '2012-10-16T21:19:08+00:00'
          FeedProcessingStatus '_SUBMITTED_'
        }
      end.doc.root
    end

    let(:in_progress_node) do
      Nokogiri::XML::Builder.new do
        FeedSubmissionInfo {
          FeedSubmissionId 5868304010
          FeedType '_POST_PRODUCT_DATA_'
          SubmittedDate '2012-10-16T21:19:08+00:00'
          FeedProcessingStatus '_IN_PROGRESS_'
          StartedProcessingDate '2012-10-16T21:21:35+00:00'
        }
      end.doc.root
    end

    let(:done_node) do
      Nokogiri::XML::Builder.new do
        FeedSubmissionInfo {
          FeedSubmissionId 5868304010
          FeedType '_POST_PRODUCT_DATA_'
          SubmittedDate '2012-10-16T21:19:08+00:00'
          FeedProcessingStatus '_DONE_'
          StartedProcessingDate '2012-10-16T21:21:35+00:00'
          CompletedProcessingDate '2012-10-16T21:23:40+00:00'
        }
      end.doc.root
    end

    it 'should not allow instance creation via new' do
      expect { SubmissionInfo.new }.to raise_error NoMethodError
    end

    describe '.from_xml' do

      it 'should be able to create an info object in a submitted state' do
        info = SubmissionInfo.from_xml submitted_node
        info.id.should == "5868304010"
        info.status.should == SubmissionInfo::Status.SUBMITTED.sym
        info.type.should == Feed::Type.PRODUCT.sym
        info.submitted.should == Time.parse('2012-10-16T21:19:08+00:00')
        info.started.should be_nil
        info.completed.should be_nil
      end

      it 'should be able to create an info object in and in progress state' do
        info = SubmissionInfo.from_xml in_progress_node
        info.id.should == "5868304010"
        info.status.should == SubmissionInfo::Status.IN_PROGRESS.sym
        info.type.should == Feed::Type.PRODUCT.sym
        info.submitted.should == Time.parse('2012-10-16T21:19:08+00:00')
        info.started.should == Time.parse('2012-10-16T21:21:35+00:00')
        info.completed.should be_nil
      end

      it 'should be able to create an info object in a done state' do
        info = SubmissionInfo.from_xml done_node
        info.id.should == "5868304010"
        info.status.should == SubmissionInfo::Status.DONE.sym
        info.type.should == Feed::Type.PRODUCT.sym
        info.submitted.should == Time.parse('2012-10-16T21:19:08+00:00')
        info.started.should == Time.parse('2012-10-16T21:21:35+00:00')
        info.completed.should == Time.parse('2012-10-16T21:23:40+00:00')
      end

    end

  end

end