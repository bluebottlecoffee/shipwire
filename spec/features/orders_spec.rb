require 'spec_helper'

RSpec.describe "Orders", type: :feature, vcr: true do
  context "list" do
    context "without params" do
      it "is successful" do
        VCR.use_cassette("orders_list") do
          response = Shipwire::Orders.list

          expect(response.ok?).to be_truthy
        end
      end
    end

    context "with params" do
      it "is successful" do
        VCR.use_cassette("orders_list_with_params") do
          response = Shipwire::Orders.list(
            status: "canceled"
          )

          expect(response.ok?).to be_truthy
        end
      end
    end
  end

  context "management" do
    let(:payload) do
      order_number = (0...8).map { (65 + rand(26)).chr }.join

      {
        orderNo: order_number,
        externalId: order_number,
        items: [
          {
            sku: "TEST-PRODUCT",
            quantity: 1
          }
        ],
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
      }
    end

    let(:payload_update) do
      payload.deeper_merge(options: { currency: "MXN" })
    end

    let!(:order) do
      VCR.use_cassette("order") do
        Shipwire::Orders.create(payload)
      end
    end

    context "create with warnings" do
      it "is successful" do
        VCR.use_cassette("order_with_warnings") do
          response = Shipwire::Orders.create(payload)

          expect(response.ok?).to be_truthy
          expect(response.has_warnings?).to be_truthy
          expect(response.warnings).to include(
            "Order was marked residential; now marked commercial"
          )

          # Cancel the order
          order_id = order.body["resource"]["items"].first["resource"]["id"]

          Shipwire::Orders.cancel(order_id)
        end
      end
    end

    context "find" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("order_find") do
            order_id = order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Orders.find(order_id)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "with params" do
        it "is successful" do
          VCR.use_cassette("order_find_with_params") do
            order_id = order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Orders.find(order_id, expand: "trackings")

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("order_find_fail") do
          response = Shipwire::Orders.find(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Order not found.'
        end
      end
    end

    context "update" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("order_update") do
            order_id = order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Orders.update(order_id, payload_update)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "with params" do
        it "is successful" do
          VCR.use_cassette("order_update_with_params") do
            order_id = order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Orders.update(order_id,
                                                  payload_update,
                                                  expand: "all")

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("order_update_fail") do
          response = Shipwire::Orders.update(0, payload_update)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq(
            "Order ID not detected. Please make a POST if you wish to create "\
            "an order."
          )
        end
      end
    end

    context "items" do
      it "is successful" do
        VCR.use_cassette("order_items") do
          order_id = order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Orders.items(order_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("order_items_fail") do
          response = Shipwire::Orders.items(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Order not found.'
        end
      end
    end

    context "holds" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("order_holds") do
            order_id = order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Orders.holds(order_id)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "with params" do
        it "is successful" do
          VCR.use_cassette("order_holds_with_params") do
            order_id = order.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Orders.holds(order_id, includeCleared: 1)

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("order_holds_fail") do
          response = Shipwire::Orders.holds(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Order not found.'
        end
      end
    end

    context "returns" do
      it "is successful" do
        VCR.use_cassette("order_returns") do
          order_id = order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Orders.returns(order_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("order_returns_fail") do
          response = Shipwire::Orders.returns(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Order not found.'
        end
      end
    end

    context "trackings" do
      it "is successful" do
        VCR.use_cassette("order_trackings") do
          order_id = order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Orders.trackings(order_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("order_trackings_fail") do
          response = Shipwire::Orders.trackings(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Order not found.'
        end
      end
    end

    context "cancel" do
      it "is successful" do
        VCR.use_cassette("order_cancel") do
          order_id = order.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Orders.cancel(order_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("order_cancel_fail") do
          response = Shipwire::Orders.cancel(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Order not found'
        end
      end
    end
  end
end
