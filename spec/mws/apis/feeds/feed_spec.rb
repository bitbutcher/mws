require 'spec_helper'

module Mws::Apis::Feeds

  describe Feed do

    context '.new' do

      let(:merchant) { 'GSWCJ4UBA31UTJ' }
      let(:message_type) { :product }

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

    end

  end

end