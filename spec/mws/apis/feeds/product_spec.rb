require 'spec_helper'
require 'nokogiri'

module Mws::Apis::Feeds

  describe 'Product' do 

    context '.new' do

      it 'should require a sku' do
        expect { Product.new }.to raise_error ArgumentError 

        sku = '12343533'
        Product.new(sku).sku.should == sku
      end

      it 'should support product builder block initialization' do
        capture = nil
        product = Product.new('123431') do 
          capture = self
        end
        capture.should be_an_instance_of Product::ProductBuilder
      end

      it 'should support building with upc, tax code, brand and name' do
        product = Product.new('12324') do
          upc '4321'
          tax_code 'GEN_TAX_CODE'
          brand 'Test Brand'
          name 'Test Product'
        end

        product.upc.should == '4321'
        product.tax_code.should == 'GEN_TAX_CODE'
        product.brand.should == 'Test Brand'
        product.name.should == 'Test Product'
      end

      it 'should support building with msrp' do
        product = Product.new('12324') do
          msrp 10.99, :usd
        end

        product.msrp.amount.should == 10.99
        product.msrp.currency.should == :usd
      end

      it 'should support building with item dimensions' do
        product = Product.new('12324') do
          item_dimensions {
            length 2, :feet
            width 3, :inches
            height 1, :meters
            weight 4, :pounds
          }
        end

        product.item_dimensions.length.value.should == 2
        product.item_dimensions.length.unit.should == :feet
        product.item_dimensions.width.value.should == 3
        product.item_dimensions.width.unit.should == :inches
        product.item_dimensions.height.value.should == 1 
        product.item_dimensions.height.unit.should == :meters
        product.item_dimensions.weight.value.should == 4 
        product.item_dimensions.weight.unit.should == :pounds
      end

      it 'should support building with package dimensions' do
        product = Product.new('12324') do
          package_dimensions {
            length 2, :feet
            width 3, :inches
            height 1, :meters
            weight 4, :pounds
          }
        end

        product.package_dimensions.length.value.should == 2
        product.package_dimensions.length.unit.should == :feet
        product.package_dimensions.width.value.should == 3
        product.package_dimensions.width.unit.should == :inches
        product.package_dimensions.height.value.should == 1 
        product.package_dimensions.height.unit.should == :meters
        product.package_dimensions.weight.value.should == 4 
        product.package_dimensions.weight.unit.should == :pounds
      end
    
      it 'should require valid package and shipping dimensions' do
        capture = self
        product = Product.new('12324') do
          package_dimensions {
            capture.expect { length 2, :foots }.to capture.raise_error ArgumentError
            capture.expect { width 2, :decades }.to capture.raise_error ArgumentError
            capture.expect { height 1, :miles }.to capture.raise_error ArgumentError
            capture.expect { weight 1, :stone }.to capture.raise_error ArgumentError
          }
        end
      end

      it 'should support building with description and bullet points' do
        product = Product.new('12343') do
          description 'This is a test product description.'
          bullet_point 'Bullet Point 1'
          bullet_point 'Bullet Point 2'
          bullet_point 'Bullet Point 3'
          bullet_point 'Bullet Point 4'
        end
        product.description.should == 'This is a test product description.'
        product.bullet_points.length.should == 4
        product.bullet_points[0].should == 'Bullet Point 1'
        product.bullet_points[1].should == 'Bullet Point 2'
        product.bullet_points[2].should == 'Bullet Point 3'
        product.bullet_points[3].should == 'Bullet Point 4'
      end


      it 'should support building with package and shipping weight' do
        product = Product.new('12343') do
          package_weight 3, :pounds
          shipping_weight 4, :ounces
        end

        product.package_weight.value.should == 3
        product.package_weight.unit.should == :pounds
        product.shipping_weight.value.should == 4
        product.shipping_weight.unit.should == :ounces
      end

      it 'should support building with product details' do
        product = Product.new '12343' do
          details {
            value 'some value'
            nested {
              foo 'bar'
              nested {
                baz 'bahhh'
              }
            }
          }
        end

        product.details.should_not be nil
        product.details[:value].should == 'some value'
        product.details[:nested][:foo].should == 'bar'
        product.details[:nested][:nested][:baz].should == 'bahhh'
      end
    end

    context '#to_xml' do

      it 'should create xml for standard attributes' do

        expected = Nokogiri::XML::Builder.new do
          Product {
            SKU '12343'
            StandardProductID {
              Type 'UPC'
              Value '432154321'
            }
            ProductTaxCode 'GEN_TAX_CODE'
            DescriptionData {
              Title 'Test Product'
              Brand 'Test Brand'
              Description 'Some product'
              BulletPoint 'Bullet Point 1'
              BulletPoint 'Bullet Point 2'
              BulletPoint 'Bullet Point 3'
              BulletPoint 'Bullet Point 4'
              ItemDimensions {
                Length 2, unitOfMeasure: 'feet'
                Width 3, unitOfMeasure: 'inches'
                Height 1, unitOfMeasure: 'meters'
                Weight 4, unitOfMeasure: 'LB'
              }
              PackageDimensions {
                Length 2, unitOfMeasure: 'feet'
                Width 3, unitOfMeasure: 'inches'
                Height 1, unitOfMeasure: 'meters'
                Weight 4, unitOfMeasure: 'LB'
              }
              PackageWeight 2, unitOfMeasure: 'LB'
              ShippingWeight 3, unitOfMeasure: 'MG'
              MSRP 19.99, currency: 'USD'
            }
          }
        end.doc.root.to_xml

        expected.should == Product.new('12343') do
          upc '432154321'
          tax_code 'GEN_TAX_CODE'
          brand 'Test Brand'
          name 'Test Product'
          description 'Some product'
          msrp 19.99, 'USD'
          bullet_point 'Bullet Point 1'
          bullet_point 'Bullet Point 2'
          bullet_point 'Bullet Point 3'
          bullet_point 'Bullet Point 4'
          item_dimensions {
            length 2, :feet
            width 3, :inches
            height 1, :meters
            weight 4, :pounds
          }
          package_dimensions {
            length 2, :feet
            width 3, :inches
            height 1, :meters
            weight 4, :pounds
          }
          package_weight 2, :pounds
          shipping_weight 3, :miligrams
        end.to_xml
        
      end

      it 'should create xml for product details' do
        expected = Nokogiri::XML::Builder.new do
          Product {
            SKU '12343'
            DescriptionData {}
            ProductData {
              CE {
                ProductType {
                  CableOrAdapter {
                    CableLength 6, unitOfMeasure: 'feet'
                  }
                }
              }
            }
          }
        end.doc.root.to_xml

        expected.should == Product.new('12343') do 
          category :ce
          details {
            cable_or_adapter {
              cable_length {
                length 6
                unit_of_measure :feet
              }
            }    
          }
        end.to_xml
      end

    end

  end

end
