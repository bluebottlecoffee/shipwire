require 'spec_helper'

RSpec.describe "Product", type: :feature, vcr: true do
  %w(base insert kit virtual_kit).each do |product_type|
    context "type #{product_type}" do
      let(:product_class) do
        type = Shipwire::Utility.camelize(product_type)

        Object.const_get("Shipwire::Products::#{type}")
      end

      context "list" do
        context "without params" do
          it "is successful" do
            VCR.use_cassette("products_#{product_type}_list") do
              response = product_class.list

              expect(response.ok?).to be_truthy
            end
          end
        end

        context "with params" do
          it "is successful" do
            VCR.use_cassette("products_#{product_type}_list_with_params") do
              response = product_class.list(
                sku: "TEST-PRODUCT"
              )

              expect(response.ok?).to be_truthy
            end
          end
        end
      end

      context "management" do
        let!(:product) do
          VCR.use_cassette("product_#{product_type}") do
            product_class.create(payload(product_type))
          end
        end

        context "find" do
          it "is successful" do
            VCR.use_cassette("product_#{product_type}_find") do
              product_id =
                product.body["resource"]["items"].first["resource"]["id"]

              response = product_class.find(product_id)

              expect(response.ok?).to be_truthy
            end
          end

          it "fails when id does not exist" do
            VCR.use_cassette("product_#{product_type}_find_fail") do
              response = product_class.find(0)

              expect(response.ok?).to be_falsy
              expect(response.error_summary).to eq 'Product not found.'
            end
          end
        end

        context "update" do
          it "is successful" do
            VCR.use_cassette("product_#{product_type}_update") do
              product_id =
                product.body["resource"]["items"].first["resource"]["id"]

              payload = payload(product_type).deeper_merge!(
                description: "Super awesome description"
              )

              response = product_class.update(product_id, payload)

              expect(response.ok?).to be_truthy
            end
          end

          it "fails when id does not exist" do
            VCR.use_cassette("product_#{product_type}_update_fail") do
              payload = payload(product_type).deeper_merge!(
                description: "Super awesome description"
              )

              response = product_class.update(0, payload)

              expect(response.ok?).to be_falsy
              expect(response.error_summary).to eq 'Product not found.'
            end
          end
        end

        context "retire" do
          context "with string passed" do
            it "is successful" do
              VCR.use_cassette("product_#{product_type}_retire_id") do
                product_id =
                  product.body["resource"]["items"].first["resource"]["id"]

                response = product_class.retire(product_id)

                expect(response.ok?).to be_truthy
              end
            end
          end

          context "with array passed" do
            it "is successful" do
              VCR.use_cassette("product_#{product_type}_retire_id") do
                product_id =
                  product.body["resource"]["items"].first["resource"]["id"]

                response = product_class.retire([product_id, 0])

                expect(response.ok?).to be_truthy
              end
            end
          end

          context "when product does not exist" do
            it "is successful" do
              VCR.use_cassette("product_#{product_type}_retire_nonexistent") do
                response = product_class.retire(0)

                expect(response.ok?).to be_truthy
              end
            end
          end
        end

        # NOTE: This is ugly and massive and I know it. I'm down to change it.
        def payload(type)
          payload = {
            sku: FFaker::Product.model,
            externalId: FFaker::Product.model,
            description: FFaker::Product.product,
            category: "OTHER",
            batteryConfiguration: "NOBATTERY",
            values: {
              costValue: 1,
              retailValue: 4
            },
            dimensions: {
              length: 1,
              width: 1,
              height: 1,
              weight: 1
            },
            flags: {
              isPackagedReadyToShip: 1,
              isFragile: 0,
              isDangerous: 0,
              isPerishable: 0,
              isLiquid: 0,
              isMedia: 0,
              isAdult: 0,
              hasInnerPack: 0,
              hasMasterCase: 0,
              hasPallet: 0
            }
          }

          # First of all, to create a Kit or Virtual Kit, the base products HAVE
          # to exist. They will not be created here. Kits require 2 ore more
          # products.
          # Next, `externalId` is NOT the same as the product SKU. An externalId
          # currently cannot be set using the Shipwire website. It can only be
          # set by creating a product through the API or updating an existing
          # product using the API and setting a value for externalID.
          # Otherwise instead of `externalID` you can use `productID` which is
          # the unique Shipwire ID for that product
          product_contents = [
            {
              externalId: "TEST-PRODUCT",
              quantity: 1
            },
            {
              externalId: "TEST-PRODUCT2",
              quantity: 1
            }
          ]

          case type
          when "insert"
            payload.deeper_merge!(
              dimensions: {
                height: 0.1,
                weight: 0.1
              },
              masterCase: {
                individualItemsPerCase: 1,
                sku: FFaker::Product.model,
                description: FFaker::Product.product,
                dimensions: {
                  length: 1,
                  width: 1,
                  height: 1,
                  weight: 1
                }
              },
              inclusionRules: {
                insertWhenWorthCurrency: "USD"
              }
            )
          when "kit"
            payload.deeper_merge!(kitContent: product_contents)

          when "virtual_kit"
            payload.deeper_merge!(virtualKitContent: product_contents)
          end

          payload
        end
      end
    end
  end
end
