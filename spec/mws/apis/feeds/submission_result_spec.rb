require 'spec_helper'
require 'nokogiri'

module Mws::Apis::Feeds

  class SubmissionResult
    attr_reader :responses
  end

  describe SubmissionResult do 
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
        result.status.should == SubmissionResult::Status.COMPLETE.sym
        result.messages_processed.should == 1
        result.count_for(:success).should == 1
        result.count_for(:error).should == 0
        result.count_for(:warning).should == 0
        result.responses.should be_empty
      end

      it 'should be able to be constructed from valid error xml' do 
        result = SubmissionResult.from_xml error_node
        result.transaction_id.should == '5868304010'
        result.status.should == SubmissionResult::Status.COMPLETE.sym
        result.messages_processed.should == 2
        result.count_for(:success).should == 0
        result.count_for(:error).should == 2
        result.count_for(:warning).should == 1
        result.responses.size.should == 3

        response = result.response_for 1
        response.type.should == SubmissionResult::Response::Type.ERROR.sym
        response.code.should == 8560
        response.description == 'Result description 1'
        response.additional_info.should == {
          sku: '3455449'
        }


        response = result.response_for 2
        response.type.should == SubmissionResult::Response::Type.ERROR.sym
        response.code.should == 5000
        response.description == 'Result description 2'
        response.additional_info.should == {
          sku: '8744969'
        }

        response = result.response_for 3
        response.type.should == SubmissionResult::Response::Type.WARNING.sym
        response.code.should == 5001
        response.description == 'Result description 3'
        response.additional_info.should == {
          sku: '7844970'
        }
      end

    end

  end

end