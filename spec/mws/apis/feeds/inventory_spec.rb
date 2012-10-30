require 'spec_helper'

module Mws::Apis::Feeds

  describe 'Inventory' do
    
    context '.new' do

      it 'should require non-nil sku' do
        expect { Inventory.new(nil, quantity: 1) }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should require a non-empty sku' do
        expect { Inventory.new('', quantity: 1) }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should require a sku that is not all whitespace' do
        expect { Inventory.new('   ', quantity: 1) }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should accept a valid value for sku' do
        Inventory.new('987612345', quantity: 1).sku.should == '987612345'
      end

      it 'should require one of available, quantity or lookup' do
        expect { Inventory.new('987612345', {}) }.to raise_error Mws::Errors::ValidationError, 
          "One and only one of 'available', 'quantity' or 'lookup' must be specified."
      end

      it 'should require a boolean value for available' do
        expect { Inventory.new('987612345', available: 1) }.to raise_error Mws::Errors::ValidationError, 
          'Available must be either true or false.'
      end

      it 'should accept a valid value for available' do
        Inventory.new('98712345', available: true).available.should be true
      end

      it 'should require quantity to be a whole number greater than or equal to zero' do
        expect { Inventory.new('987612345', quantity: -1) }.to raise_error Mws::Errors::ValidationError, 
          'Quantity must be a whole number greater than or equal to zero.'
      end

      it 'should accept a valid value for quantity' do
        Inventory.new('987612345', quantity: 1).quantity.should == 1
      end

      it 'should require a boolean value for lookup' do
        expect { Inventory.new('987612345', lookup: 'Yes') }.to raise_error Mws::Errors::ValidationError,
          'Lookup must be either true or false.'
      end

      it 'should accept a valid value for lookup' do
        Inventory.new('987612345', lookup: true).lookup.should be true
      end

      it 'should accept only one of available, quantity or lookup' do
        expect {
          Inventory.new('987612345', available: true, quantity: 1, lookup: 'FulfillmentNetwork')
        }.to raise_error Mws::Errors::ValidationError, 
          "One and only one of 'available', 'quantity' or 'lookup' must be specified."
      end

      it 'should accept a valid fulfillment center' do
        Inventory.new('987612345', quantity: 1, fulfillment_center: 'foo').fulfillment.center.should == 'foo'
      end

      it 'should require fulfillment latency to be a whole number greater than zero' do
        expect { 
          Inventory.new('987612345', quantity: 1, fulfillment_latency: 0) 
        }.to raise_error Mws::Errors::ValidationError,
          'Fulfillment latency must be a whole number greater than zero.'
      end

      it 'should accept a valid fulfillment latency' do
        Inventory.new('987612345', quantity: 1, fulfillment_latency: 1).fulfillment.latency.should == 1
      end

      it 'should require fulfillment type to be either AFN or MFN' do
        expect {
          Inventory.new('987612345', quantity: 1, fulfillment_type: 'foo')
        }.to raise_error Mws::Errors::ValidationError,
          "Fulfillment type must be either 'AFN' or 'MFN'."
      end

      it 'should accept a valid fulfillment type' do
        Inventory.new('987612345', quantity: 1, fulfillment_type: :mfn).fulfillment.type.should == :mfn 
      end

      it 'should require the restock date to be in the future' do
        expect {
          Inventory.new('987612345', quantity: 0, restock: Time.now)
        }.to raise_error Mws::Errors::ValidationError,
          'Restock date must be in the future.'
      end

      it 'should accept a valid restock date' do
        restock = 4.days.from_now
        Inventory.new('987612345', quantity: 0, restock: restock).restock.should == restock
      end

    end

    context '#xml_for' do

      it 'should properly serialize to XML' do
        restock = 4.days.from_now
        inventory = Inventory.new('987612345', 
          quantity: 5, 
          fulfillment_center: 'A1B2C3D4E5',
          fulfillment_latency: 3,
          fulfillment_type: :mfn,
          restock: restock
        )
        expected = Nokogiri::XML::Builder.new do
          Inventory {
            SKU '987612345'
            FulfillmentCenterID 'A1B2C3D4E5'
            Quantity 5
            RestockDate restock.iso8601
            FulfillmentLatency 3
            SwitchFulfillmentTo 'MFN'
          }
        end.doc.root.to_xml
        inventory.to_xml.should == expected
      end

    end

  end

end