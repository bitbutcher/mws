require 'spec_helper'

module Mws::Apis::Feeds

  describe 'PriceListing' do

    context '.new' do

      it 'should be able to construct a price with only sku and base price' do
        price = PriceListing.new('987612345', 14.99)
        price.sku.should == '987612345'
        price.currency.should == :usd
        price.base.should == MonetaryAmount.new(14.99, :usd)
        price.min.should be nil
        price.sale.should be nil
      end

      it 'should be able to construct a price with custom currency code' do
        price = PriceListing.new('9876123456', 14.99, currency: 'EUR')
        price.currency.should == 'EUR'
        price.base.should == MonetaryAmount.new(14.99, 'EUR')
      end

      it 'should be able to construct a price with custom minimum advertised price' do
        price = PriceListing.new('987612345', 14.99, min: 11.99)
        price.min.should == MonetaryAmount.new(11.99, :usd)
      end

      it 'should be able to construct a new price with custom sale price' do
        from = 1.day.ago
        to = 4.months.from_now
        price = PriceListing.new('987612345', 14.99, sale: {
          amount: 12.99,
          from: from,
          to: to
        })
        price.sale.should == SalePrice.new(MonetaryAmount.new(12.99, :usd), from, to)
      end

      it 'should validate that the base price is less than the minimum advertised price' do
        expect {
          PriceListing.new('987612345', 9.99, min: 10.00)
        }.to raise_error RuntimeError, "'Base Price' must be greater than 'Minimum Advertised Price'."
      end

      it 'should validate that the sale price is less than the minimum advertised price' do
        expect {
          PriceListing.new('987612345', 14.99, min: 10.00).on_sale(9.99, 1.day.ago, 4.months.from_now)
        }.to raise_error RuntimeError, "'Sale Price' must be greater than 'Minimum Advertised Price'."
      end

    end

    context '#on_sale' do

      it 'should provide a nicer syntax for specifying the sale price' do
        from = 1.day.ago
        to = 4.months.from_now
        price = PriceListing.new('987612345', 14.99).on_sale(12.99, from, to)
        price.sale.should == SalePrice.new(MonetaryAmount.new(12.99, :usd)  , from, to)
      end

    end

    context '#to_xml' do

      it 'should properly serialize to XML' do
        from = 1.day.ago
        to = 4.months.from_now
        price = PriceListing.new('987612345', 14.99, currency: :eur, min: 10.99).on_sale(12.99, from, to)
        expected = Nokogiri::XML::Builder.new do
          Price {
            SKU '987612345'
            StandardPrice '14.99', currency: 'EUR'
            MAP '10.99', currency: 'EUR'
            Sale {
              StartDate from.iso8601
              EndDate to.iso8601
              SalePrice '12.99', currency: 'EUR'
            }
          }
        end.doc.root.to_xml
        price.to_xml.should == expected
      end

    end

  end

end