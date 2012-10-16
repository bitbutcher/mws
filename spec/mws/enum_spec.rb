require 'spec_helper'

module Mws

  describe 'Enum' do

    let (:options) do 
      {
        pending: 'Pending',
        unshipped: [ 'Unshipped', 'PartiallyShipped' ],
        shipped: 'Shipped',
        invoice_unconfirmed: 'InvoiceUnconfirmed',
        cancelled: 'Cancelled',
        unfulfillable: 'Unfulfillable'
      }
    end

    it 'should not allow instance creation via new' do
      expect { Enum.new }.to raise_error NoMethodError
    end

    it 'should construct a constant-like accessor for each provided symbol' do
      OrderStatus = Enum.for options
      options.each do | key, value |
        OrderStatus.send(key.to_s.upcase.to_sym).should_not be nil?
      end
    end

    it 'should be able to find an enum entry from a symbol' do
      OrderStatus = Enum.for options
      OrderStatus.for(:pending).should == OrderStatus.PENDING
    end

    it 'should be able to find an enum entry from a string' do
      OrderStatus = Enum.for options
      OrderStatus.for('Pending').should == OrderStatus.PENDING
    end

    it 'should be able to provide a symbol for an entry' do
      OrderStatus = Enum.for options
      OrderStatus.PENDING.sym.should == :pending
    end

    it 'should be able to provide a value for an enum entry' do
      OrderStatus = Enum.for options
      OrderStatus.PENDING.val.should == 'Pending'
    end

    it 'should be able to handle multivalued enum entries' do
      OrderStatus = Enum.for options
      OrderStatus.for(:unshipped).should == OrderStatus.UNSHIPPED
      OrderStatus.for('Unshipped').should == OrderStatus.UNSHIPPED
      OrderStatus.for('PartiallyShipped').should == OrderStatus.UNSHIPPED
    end

  end

end