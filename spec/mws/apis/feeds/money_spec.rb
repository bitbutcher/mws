require 'spec_helper'

module Mws::Apis::Feeds

  describe 'Money' do

    context '.new' do

      it 'should default to usd' do
        money = Money.new 40
        money.amount.should == 40
        money.unit.should == :usd
      end

      it 'should accept a valid currency override' do
        money = Money.new 0, :eur
        money.amount.should == 0
        money.unit.should == :eur
      end

      it 'should validate the currency override' do
        expect {
          Money.new 40, :acres
        }.to raise_error ArgumentError, "Invalid currency 'acres'"
      end

    end

    context '#to_xml' do

      it 'should properly serialize to XML' do
        money = Money.new 25, :cad
        expected = Nokogiri::XML::Builder.new do
          Price '25.00', currency: 'CAD'
        end.doc.root.to_xml
        money.to_xml.should == expected
      end

    end

  end
  
end