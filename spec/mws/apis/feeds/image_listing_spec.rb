require 'spec_helper'

module Mws::Apis::Feeds

  describe ImageListing do

    let(:sku) { '987612345' }
    let(:url) { 'http://domain.com/images/foo.png' }
    let(:type) { :alt1 }
    let(:listing) { ImageListing.new sku, url, type }

    context '.new' do

      it 'should construct an image listing with url and type' do
        listing.sku.should == sku
        listing.url.should == url
        listing.type.should == type
      end

      it 'should default the image listing type to main' do
        listing = ImageListing.new sku, url
        listing.sku.should == sku
        listing.url.should == url
        listing.type.should == :main
      end

      it 'should require non-nil sku' do
        expect { ImageListing.new(nil, url) }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should require a non-empty sku' do
        expect { ImageListing.new('', url) }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should require a sku that is not all whitespace' do
        expect { ImageListing.new('   ', url) }.to raise_error Mws::Errors::ValidationError, 
          'SKU is required.'
      end

      it 'should require a non-nil url' do
        expect { ImageListing.new(sku, nil) }.to raise_error Mws::Errors::ValidationError,
          'URL must be an unsecured http address.'
      end

      it 'should require a valid url' do
        expect { ImageListing.new(sku, 'this is not a url') }.to raise_error Mws::Errors::ValidationError,
          'URL must be an unsecured http address.'
      end

      it 'should require an http url' do
        expect { ImageListing.new(sku, 'ftp://domain.com/images/foo.png') }.to raise_error Mws::Errors::ValidationError,
          'URL must be an unsecured http address.'
      end

      it 'should require an unsecure url' do
        expect { ImageListing.new(sku, 'https://domain.com/images/foo.png') }.to raise_error Mws::Errors::ValidationError,
          'URL must be an unsecured http address.'
      end

    end

    context '#==' do

      it 'should be reflexive' do
        (listing == listing).should be true
      end

      it 'should be symmetric' do
        a = listing
        b = ImageListing.new(sku, url, type)
        c = ImageListing.new(sku, url)
        (a == b).should == (b == a)
        (a == c).should == (c == a)
      end

      it 'should be transitive' do
        a = listing
        b = ImageListing.new(sku, url, type)
        c = ImageListing.new(sku, url, type)
        (a == c).should == (a == b && b == c)
      end

      it 'should handle comparison to nil' do
        (listing == nil).should be false
      end

    end

    context '#to_xml' do

      it 'shoud properly serialize to xml' do
        expected = Nokogiri::XML::Builder.new {
          ProductImage {
            SKU sku
            ImageType 'PT1'
            ImageLocation url
          }
        }.doc.root.to_xml
        actual = listing.to_xml
        actual.should == expected
      end

    end

  end

end