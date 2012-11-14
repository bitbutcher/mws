require 'spec_helper'

module Mws::Apis::Feeds

  describe 'Shipping' do

    context '.new' do

      it 'should require non-nil sku' do
        expect { Shipping.new(nil) }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should require a non-empty sku' do
        expect { Shipping.new('') }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should require a sku that is not all whitespace' do
        expect { Shipping.new('   ') }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should accept a valid value for sku' do
        Shipping.new('987612345').sku.should == '987612345'
      end

      it 'should accept a block to associate shipping option overrides' do
        shipping = Shipping.new('987612345') do
          replace 4.99, :usd, :continental_us, :standard, :street
        end
        shipping.sku.should == '987612345'
        shipping.options.size.should == 1
        override = shipping.options.first
        override.amount.should == Mws::Money(4.99, :usd)
        # override.option.should == Shipping::Option.new(:continental_us, :standard, :street)
        override.option.region.should == :continental_us
        override.option.speed.should == :standard
        override.option.variant.should == :street
      end

    end

    context '#to_s' do

      it 'should properly encode as a string' do
        shipping = Shipping.new('987612345') do
          replace 19.99, :usd, :continental_us, :two_day, :street
          replace 29.99, :usd, :continental_us, :one_day, :street
        end
        shipping.options.first.option.to_s.should == 'Second'
        shipping.options.last.option.to_s.should == 'Next'
      end

    end

  end

end