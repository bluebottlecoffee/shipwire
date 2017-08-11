require 'spec_helper'

RSpec.describe "Returns", type: :feature, vcr: true do
  context "list" do
    context "without params" do
      it "is successful" do
        VCR.use_cassette("returns_list") do
          response = Shipwire::Returns.list

          expect(response.ok?).to be_truthy
        end
      end
    end

    context "using params" do
      it "is successful" do
        VCR.use_cassette("returns_list_with_params") do
          response = Shipwire::Returns.list(
            status: "canceled"
          )

          expect(response.ok?).to be_truthy
        end
      end
    end
  end

  context "management" do
    # Took me WAY too long to realize I can't use the variable `return`
    let!(:return_order) do
      VCR.use_cassette("return") do
        items = [{
          sku: "TEST-PRODUCT",
          quantity: 1
        }]

        order = Shipwire::Orders.create(
          orderNo: FFaker::Product.model,
          items: items,
          options: {
            currency: "USD"
          },
          shipTo: {
            email: FFaker::Internet.email,
            name: FFaker::Name.name,
            address1: "540 West Boylston St.",
            city: "Worcester",
            state: "MA",
            postalCode: "01606",
            country: "US",
            phone: FFaker::PhoneNumber.short_phone_number
          }
        )

        order_id = order.body["resource"]["items"].first["resource"]["id"]

        # There is an issue with returns. You can't create an order, then
        # immediately return it. This is the functionality that a test would be
        # doing. There is some kind of processing that needs to happen on
        # Shipwire's end. Whatever needs to happen on their end takes time. The
        # only way I was ever able to get the returns to work was to put a
        # `binding.pry` between the part where it create an order and the part
        # where it returns the order. Let it sit for about 5 minutes. Take a
        # restroom break. Eat a snack. Then let the tests continue as normal.
        Shipwire::Returns.create(
          originalOrder: {
            id: order_id
          },
          items: items,
          options: {
            emailCustomer: 0
          }
        )
      end
    end

    context "find" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("return_find") do
            return_id =
              return_order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Returns.find(return_id)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "using params" do
        it "is successful" do
          VCR.use_cassette("return_find_with_params") do
            return_id =
              return_order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Returns.find(return_id, expand: "items")

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("return_find_fail") do
          response = Shipwire::Returns.find(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "holds" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("return_holds") do
            return_id =
              return_order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Returns.holds(return_id)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "using params" do
        it "is successful" do
          VCR.use_cassette("return_holds_with_params") do
            return_id =
              return_order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Returns.holds(return_id, includeCleared: 0)

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("return_holds_fail") do
          response = Shipwire::Returns.holds(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "items" do
      it "is successful" do
        VCR.use_cassette("return_items") do
          return_id =
            return_order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Returns.items(return_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("return_items_fail") do
          response = Shipwire::Returns.items(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "trackings" do
      it "is successful" do
        VCR.use_cassette("return_trackings") do
          return_id =
            return_order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Returns.trackings(return_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("return_trackings_fail") do
          response = Shipwire::Returns.trackings(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "labels" do
      it "is successful" do
        VCR.use_cassette("return_labels") do
          return_id =
            return_order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Returns.labels(return_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("return_labels_fail") do
          response = Shipwire::Returns.labels(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Label not found.'
        end
      end
    end

    context "cancel" do
      it "is successful" do
        VCR.use_cassette("return_cancel") do
          return_id =
            return_order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Returns.cancel(return_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("return_cancel_fail") do
          response = Shipwire::Returns.cancel(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Return Order not found.'
        end
      end
    end
  end
end
