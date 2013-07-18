require 'spec_helper'

module Mws

  describe Serializer do

    let(:from) { 1.day.from_now }
    let(:to) { 3.months.from_now }
    let(:regular_price) { 21.99 }
    let(:sale_price) { 14.99 }

    context '.tree' do

      it 'should properly serialize without a parent' do
        expected = Nokogiri::XML::Builder.new {
          Sale {
            StartDate from.iso8601
            EndDate to.iso8601
            SalePrice sale_price, currency: 'USD'
          }
        }.doc.root.to_xml
        actual = Serializer.tree 'Sale', nil do | xml |
          xml.StartDate from.iso8601
          xml.EndDate to.iso8601
          xml.SalePrice sale_price, currency: 'USD'
        end
        actual.should == expected
      end

      it 'should properly serialize with a parent' do
        sku = '7890123456'
        expected = Nokogiri::XML::Builder.new {
          Price {
            SKU sku
            StandardPrice regular_price, currency: 'USD'
            Sale {
              StartDate from.iso8601
              EndDate to.iso8601
              SalePrice sale_price, currency: 'USD'
            }
          }
        }.to_xml
        actual = Nokogiri::XML::Builder.new {
          Price {
            SKU sku
            StandardPrice regular_price, currency: 'USD'
            actual = Serializer.tree 'Sale', self do | xml |
              xml.StartDate from.iso8601
              xml.EndDate to.iso8601
              xml.SalePrice sale_price, currency: 'USD'
            end
          }
        }.to_xml
        actual.should == expected
      end

    end

    context '.leaf' do

      it 'should properly serialize without a parent' do
        expected = Nokogiri::XML::Builder.new {
          SalePrice sale_price, currency: 'USD'
        }.doc.root.to_xml
        actual = Serializer.leaf 'SalePrice', nil, sale_price, currency: 'USD'
        actual.should == expected
      end

      it 'should properly serialize with a parent' do
        expected = Nokogiri::XML::Builder.new {
          Sale {
            StartDate from.iso8601
            EndDate to.iso8601
            SalePrice sale_price, currency: 'USD'
          }
        }.to_xml
        actual = Nokogiri::XML::Builder.new {
          Sale {
            StartDate from.iso8601
            EndDate to.iso8601
            Serializer.leaf 'SalePrice', self, sale_price, currency: 'USD'
          }
        }.to_xml
        actual.should == expected
      end

    end

    context '#xml_for' do

      let(:data) do
        {
          foo: 'Bar',
          foo_bar: {
            baz_quk: 'FooBarBazQuk'
          },
          baz: [
            'Foo',
            'Bar',
            'Baz',
            'Quk'
          ],
          price: Mws::Money(regular_price, :usd)
        }
      end

      it 'should work with no exceptions' do
        expected = Nokogiri::XML::Builder.new {
          Data {
            Foo 'Bar'
            FooBar {
              BazQuk 'FooBarBazQuk'
            }
            Baz 'Foo'
            Baz 'Bar'
            Baz 'Baz'
            Baz 'Quk'
            Price regular_price, currency: 'USD'
          }
        }.to_xml
        actual = Nokogiri::XML::Builder.new
        Serializer.new.xml_for('Data', data, actual)
        actual.to_xml.should == expected
      end

      it 'should work with exceptions' do
        expected = Nokogiri::XML::Builder.new {
          Data {
            FOO 'Bar'
            FooBar {
              BazQuk 'FooBarBazQuk'
            }
            BaZ 'Foo'
            BaZ 'Bar'
            BaZ 'Baz'
            BaZ 'Quk'
            Price regular_price, currency: 'USD'
          }
        }.to_xml
        actual = Nokogiri::XML::Builder.new
        Serializer.new(foo: 'FOO', baz: 'BaZ').xml_for('Data', data, actual)
        actual.to_xml.should == expected
      end

    end

    context '#hash_for' do

      let(:xml) do
        Nokogiri::XML::Builder.new {
          Data {
            FOO 'Bar'
            FooBar {
              BazQuk 'FooBarBazQuk'
            }
            BaZ 'Foo'
            BaZ 'Bar'
            BaZ 'Baz'
            BaZ 'Quk'
            Price regular_price, currency: 'USD'
          }
        }.doc.root
      end

      it 'should work with exceptions' do
        expected = {
          foo: 'Bar',
          foo_bar: {
            baz_quk: 'FooBarBazQuk'
          },
          baz: [
            'Foo',
            'Bar',
            'Baz',
            'Quk'
          ],
          price: regular_price.to_s
        }
        actual = Serializer.new(foo: 'FOO', baz: 'BaZ').hash_for(xml, nil)
        actual.should == expected
      end

    end

  end

end