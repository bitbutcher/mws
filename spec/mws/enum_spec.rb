require 'spec_helper'

module Mws

  describe Enum do

    options = {
      pending: 'Pending',
      unshipped: [ 'Unshipped', 'PartiallyShipped' ],
      shipped: 'Shipped',
      invoice_unconfirmed: 'InvoiceUnconfirmed',
      cancelled: 'Cancelled',
      unfulfillable: 'Unfulfillable'
    }

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

    context '.sym_reader' do

      class HasEnumAttrs

        EnumOne = Enum.for( foo: 'Foo', bar: 'Bar', baz: 'Baz' )

        EnumTwo = Enum.for( bar: 'BAR', baz: 'BAZ', quk: 'QUK' )

        Enum.sym_reader self, :one, :two

        def initialize(one, two)
          @one = EnumOne.for(one)
          @two = EnumTwo.for(two)
        end

      end

      it 'should synthesize a attr_reader that exposes an enum entry as a symbol' do
        it = HasEnumAttrs.new(:foo, :quk)
        it.send(:instance_variable_get, '@one').should == HasEnumAttrs::EnumOne.FOO
        it.one.should == :foo
        it.send(:instance_variable_get, '@two').should == HasEnumAttrs::EnumTwo.QUK
        it.two.should == :quk
      end

      it 'should synthesize attr_readers that are null safe' do
        it = HasEnumAttrs.new(:quk, :foo)
        it.one.should be nil
        it.two.should be nil
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

    context '#sym' do

      it 'should return nil for nil value' do
        OrderStatus.sym(nil).should be nil
      end

      it 'should return nil for an unknown value' do
        OrderStatus.sym('UnknownValue').should be nil
      end

      it 'should provide the symbol for a given value' do
        OrderStatus.sym('Pending').should == :pending
        OrderStatus.sym('Unshipped').should == :unshipped
        OrderStatus.sym('PartiallyShipped').should == :unshipped
        OrderStatus.sym('Shipped').should == :shipped
        OrderStatus.sym('Cancelled').should == :cancelled
        OrderStatus.sym('Unfulfillable').should == :unfulfillable
      end

    end

    context '#val' do

      it 'should return nil for nil symbol' do
        OrderStatus.val(nil).should be nil
      end

      it 'should return nil for an unknown sumbol' do
        OrderStatus.val(:unknown).should be nil
      end

      it 'should provide the value for a given symbol' do
        OrderStatus.val(:pending).should == 'Pending'
        OrderStatus.val(:unshipped).should == [ 'Unshipped', 'PartiallyShipped' ]
        OrderStatus.val(:shipped).should == 'Shipped'
        OrderStatus.val(:cancelled).should == 'Cancelled'
        OrderStatus.val(:unfulfillable).should == 'Unfulfillable'
      end

    end

    context '#syms' do

      it 'should provide the set of symbols' do
        OrderStatus.syms.should == options.keys
      end

    end

    context '#vals' do

      it 'should provide the list of values' do
        OrderStatus.vals.should == options.values.flatten
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
