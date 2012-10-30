require 'spec_helper'
require 'nokogiri'

module Mws::Apis::Feeds

  class SubmissionResult
    attr_reader :message_results
  end

  describe 'SubmissionResult' do 
    let(:success_node) do
      Nokogiri::XML::Builder.new do
        Message {
          MessageID 1
          ProcessingReport {
            DocumentTransactionID 5868304010
            StatusCode 'Complete'
            ProcessingSummary {
              MessagesProcessed 1
              MessagesSuccessful 1
              MessagesWithError 0
              MessagesWithWarning 0
            }
          }
        }
      end.doc.root
    end
    let(:error_node) do
      Nokogiri::XML::Builder.new do
        Message {
          MessageID 1
          ProcessingReport {
            DocumentTransactionID 5868304010
            StatusCode 'Complete'
            ProcessingSummary {
              MessagesProcessed 2
              MessagesSuccessful 0
              MessagesWithError 2
              MessagesWithWarning 1
            }
            Result {
              MessageID 1
              ResultCode 'Error'
              ResultMessageCode 8560
              ResultDescription 'Result description 1'
              AdditionalInfo {
                SKU '3455449'
              }
            }
            Result {
              MessageID 2
              ResultCode 'Error'
              ResultMessageCode 5000
              ResultDescription "Result description 2"
              AdditionalInfo {
                SKU '8744969'
              }
            }
            Result {
              MessageID 3
              ResultCode 'Warning'
              ResultMessageCode 5001
              ResultDescription "Result description 3"
              AdditionalInfo {
                SKU '7844970'
              }
            }
          }
        }
      end.doc.root
    end

    it 'should not allow instance creation via new' do
      expect { SubmissionResult.new }.to raise_error NoMethodError
    end

    describe '.from_xml' do

      it 'should be able to be constructed from valid success xml' do
        result = SubmissionResult.from_xml success_node
        result.transaction_id.should == '5868304010'
        result.status.should == Mws::Apis::Feeds::SubmissionResult::Status.COMPLETE.sym
        result.message_count.should == 1
        result.message_count(:success).should == 1
        result.message_count(:error).should == 0
        result.message_count(:warning).should == 0
        result.message_results.should be_empty
      end

      it 'should be able to be constructed from valid error xml' do 
        result = SubmissionResult.from_xml error_node
        result.transaction_id.should == '5868304010'
        result.status.should == Mws::Apis::Feeds::SubmissionResult::Status.COMPLETE.sym
        result.message_count.should == 2
        result.message_count(:success).should == 0
        result.message_count(:error).should == 2
        result.message_count(:warning).should == 1
        result.message_results.size.should == 3

        message = result.message_for 1
        message.result.should == Mws::Apis::Feeds::SubmissionResult::MessageResultCode.ERROR.sym
        message.code.should == 8560
        message.description == 'Result description 1'
        message.additional_info.should == {
          sku: '3455449'
        }


        message = result.message_for 2
        message.result.should == Mws::Apis::Feeds::SubmissionResult::MessageResultCode.ERROR.sym
        message.code.should == 5000
        message.description == 'Result description 2'
        message.additional_info.should == {
          sku: '8744969'
        }

        message = result.message_for 3
        message.result.should == Mws::Apis::Feeds::SubmissionResult::MessageResultCode.WARNING.sym
        message.code.should == 5001
        message.description == 'Result description 3'
        message.additional_info.should == {
          sku: '7844970'
        }
      end

    end

  end

end