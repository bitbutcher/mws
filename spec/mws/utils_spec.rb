require 'spec_helper'

module Mws

  module Foo

    module Bar

      class Baz

        def initialize(quk)
          @quk = quk
        end

      end

      class Quk

        def initialize(bar)
          @bar = bar
        end

      end

    end

  end

  describe Utils do

    context '.camelize' do

      it 'should properly camelize nil' do
        Utils.camelize(nil).should be nil
        Utils.camelize(nil, false).should be nil
      end

      it 'should properly camelize the empty string' do
        Utils.camelize('').should == ''
        Utils.camelize('', false) == ''
      end

      it 'should trim whitespace from the string' do
        Utils.camelize('   ').should == ''
        Utils.camelize('   ', false) == ''
        Utils.camelize('  foo_bar_baz    ').should == 'FooBarBaz'
        Utils.camelize(' foo_bar_baz  ', false).should == 'fooBarBaz'
      end

      it 'should properly camelize single segment names' do
        Utils.camelize('foo').should == 'Foo'
        Utils.camelize('foo', false).should == 'foo'
      end

      it 'should properly camelize multi-segment names' do
        Utils.camelize('foo_bar_baz').should == 'FooBarBaz'
        Utils.camelize('foo_bar_baz', false).should == 'fooBarBaz'
      end

      it 'should properly camelize mixed case multi-segment names' do
        Utils.camelize('fOO_BAR_BAZ').should == 'FooBarBaz'
        Utils.camelize('fOO_BAR_BAZ', false).should == 'fooBarBaz'
      end

    end

    context '.underscore' do

      it 'should properly underscore nil' do
        Utils.underscore(nil).should be nil
      end

      it 'should properly camelize the empty string' do
        Utils.underscore('').should == ''
      end

      it 'should trim whitespace from the string' do
        Utils.underscore('   ').should == ''
        Utils.underscore('  FooBarBaz    ').should == 'foo_bar_baz'
      end

      it 'should properly underscore single-segment names' do
        Utils.underscore('Foo').should == 'foo'
        Utils.underscore('foo').should == 'foo'
      end

      it 'should properly underscore multi-segment names' do
        Utils.underscore('FooBarBaz').should == 'foo_bar_baz'
      end

    end

    context '.uri_escape' do

      {
        ' ' => '20',
        '"' => '22',
        '#' => '23',
        '$' => '24',
        '%' => '25',
        '&' => '26',
        '+' => '2B',
        ',' => '2C',
        '/' => '2F',
        ':' => '3A',
        ';' => '3B',
        '<' => '3C',
        '=' => '3D',
        '>' => '3E',
        '?' => '3F',
        '@' => '40',
        '[' => '5B',
        '\\' => '5C',
        ']' => '5D',
        '^' => '5E',
        '{' => '7B',
        '|' => '7C',
        '}' => '7D'
      }.each do | key, value |
        it "should properly escape '#{key}' as '%#{value}'" do
          Utils.uri_escape("foo#{key}bar").should == "foo%#{value}bar"
        end
      end

    end

    context '.alias' do

      before(:all) do
        Utils.alias Mws, Mws::Foo::Bar, :Baz, :Quk
      end

      it 'should create aliases of the specified constants' do
        Mws::Baz.should == Mws::Foo::Bar::Baz
        Mws::Quk.should == Mws::Foo::Bar::Quk
      end

      it 'should create constructor shortcuts' do
        Mws::Baz('quk').should be_a Mws::Foo::Bar::Baz
        Mws::Quk('baz').should be_a Mws::Foo::Bar::Quk
      end

    end

  end

end