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

    before(:all) do
      OrderStatus = Enum.for options
    end

    it 'should not allow instance creation via new' do
      expect { Enum.new }.to raise_error NoMethodError
    end

    context '.for' do

      it 'should construct a pseudo-constant accessor for each provided symbol' do
        options.each do | key, value |
          OrderStatus.send(key.to_s.upcase.to_sym).should_not be nil
        end
      end

      it 'should not share pseudo-constants between enumeration instances' do
        EnumOne = Enum.for( foo: 'Foo', bar: 'Bar', baz: 'Baz' )
        EnumTwo = Enum.for( bar: 'BAR', baz: 'BAZ', quk: 'QUK' )
        expect { EnumOne.QUK }.to raise_error NoMethodError
        expect { EnumTwo.FOO }.to raise_error NoMethodError
        EnumOne.BAR.should_not == EnumTwo.BAR
      end

    end

    context '#for' do

      it 'should be able to find an enum entry from a symbol' do
        OrderStatus.for(:pending).should == OrderStatus.PENDING
      end

      it 'should be able to find an enum entry from a string' do
        OrderStatus.for('Pending').should == OrderStatus.PENDING
      end

      it 'should be able to find an enum entry from an enum entry' do
        OrderStatus.for(OrderStatus.PENDING).should == OrderStatus.PENDING
      end
      
    end

    it 'should be able to provide a symbol for an entry' do
      OrderStatus.PENDING.sym.should == :pending
    end

    it 'should be able to provide a value for an enum entry' do
      OrderStatus.PENDING.val.should == 'Pending'
    end

    it 'should be able to handle multivalued enum entries' do
      OrderStatus.for(:unshipped).should == OrderStatus.UNSHIPPED
      OrderStatus.for('Unshipped').should == OrderStatus.UNSHIPPED
      OrderStatus.for('PartiallyShipped').should == OrderStatus.UNSHIPPED
    end
    
  end

end