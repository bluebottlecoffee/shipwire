require 'spec_helper'
require 'date'

RSpec.describe "Receivings", type: :feature, vcr: true do
  # Creating, updating, and canceling take an uncommonly long time on Shipwire's
  # end. Update the timeout to be safe.
  before { Shipwire.configuration.timeout = 10 }

  context "list" do
    context "without params" do
      it "is successful" do
        VCR.use_cassette("receivings_list") do
          response = Shipwire::Receivings.list

          expect(response.ok?).to be_truthy
        end
      end
    end

    context "using params" do
      it "is successful" do
        VCR.use_cassette("receivings_list_with_params") do
          response = Shipwire::Receivings.list(
            status: "canceled"
          )

          expect(response.ok?).to be_truthy
        end
      end
    end
  end

  context "management" do
    let!(:receiving) do
      VCR.use_cassette("receiving") do
        Shipwire::Receivings.create(payload)
      end
    end

    context "find" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("receiving_find") do
            receiving_id =
              receiving.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Receivings.find(receiving_id)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "using params" do
        it "is successful" do
          VCR.use_cassette("receiving_find_with_params") do
            receiving_id =
              receiving.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Receivings.find(receiving_id,
                                                    expand: "holds")

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_find_fail") do
          response = Shipwire::Receivings.find(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "update" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("receiving_update") do
            receiving_id =
              receiving.body["resource"]["items"].first["resource"]["id"]

            payload_updates = { shipFrom: { email: FFaker::Internet.email } }
            payload_update  = payload.deeper_merge(payload_updates)

            response = Shipwire::Receivings.update(receiving_id,
                                                      payload_update)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "using params" do
        it "is successful" do
          VCR.use_cassette("receiving_update_with_params") do
            receiving_id =
              receiving.body["resource"]["items"].first["resource"]["id"]

            payload_updates = { shipFrom: { email: FFaker::Internet.email } }
            payload_update  = payload.deeper_merge(payload_updates)

            response = Shipwire::Receivings.update(receiving_id,
                                                      payload_update,
                                                      expand: "all")

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_update_fail") do
          payload_updates = { shipFrom: { email: FFaker::Internet.email } }
          payload_update  = payload.deeper_merge(payload_updates)

          response = Shipwire::Receivings.update(0, payload_update)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq(
            "Order ID not detected. Please make a POST if you wish to create "\
            "an order."
          )
        end
      end
    end

    context "labels_cancel" do
      it "is successful" do
        VCR.use_cassette("receiving_cancel_label") do
          receiving_id =
            receiving.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Receivings.labels_cancel(receiving_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "is successful even when id does not exist" do
        VCR.use_cassette("receiving_cancel_label_nonexistent") do
          response = Shipwire::Receivings.labels_cancel(0)

          expect(response.ok?).to be_truthy
        end
      end
    end

    context "holds" do
      context "without params" do
        it "is successful" do
          VCR.use_cassette("receiving_holds") do
            receiving_id =
              receiving.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Receivings.holds(receiving_id)

            expect(response.ok?).to be_truthy
          end
        end
      end

      context "using params" do
        it "is successful" do
          VCR.use_cassette("receiving_holds_with_params") do
            receiving_id =
              receiving.body["resource"]["items"].first["resource"]["id"]

            response = Shipwire::Receivings.holds(receiving_id,
                                                     includeCleared: 0)

            expect(response.ok?).to be_truthy
          end
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_holds_fail") do
          response = Shipwire::Receivings.holds(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "instructions_recipients" do
      it "is successful" do
        VCR.use_cassette("receiving_instructions_recipients") do
          receiving_id =
            receiving.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Receivings.instructions(receiving_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_instructions_recipients_fail") do
          response = Shipwire::Receivings.instructions(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "items" do
      it "is successful" do
        VCR.use_cassette("receiving_items") do
          receiving_id =
            receiving.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Receivings.items(receiving_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_items_fail") do
          response = Shipwire::Receivings.items(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "shipments" do
      it "is successful" do
        VCR.use_cassette("receiving_shipments") do
          receiving_id =
            receiving.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Receivings.shipments(receiving_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_shipments_fail") do
          response = Shipwire::Receivings.shipments(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "trackings" do
      it "is successful" do
        VCR.use_cassette("receiving_tracking") do
          receiving_id =
            receiving.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Receivings.trackings(receiving_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_tracking_fail") do
          response = Shipwire::Receivings.trackings(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving Order not found.'
        end
      end
    end

    context "cancel" do
      it "is successful" do
        VCR.use_cassette("receiving_cancel") do
          receiving_id =
            receiving.body["resource"]["items"].first["resource"]["id"]

          response = Shipwire::Receivings.cancel(receiving_id)

          expect(response.ok?).to be_truthy
        end
      end

      it "fails when id does not exist" do
        VCR.use_cassette("receiving_cancel") do
          response = Shipwire::Receivings.cancel(0)

          expect(response.ok?).to be_falsy
          expect(response.error_summary).to eq 'Receiving not found'
        end
      end
    end

    def payload
      {
        externalId: FFaker::Product.model,
        expectedDate: DateTime.now.to_s,
        arrangement: {
          type: "none"
        },
        items: [{
          sku: "TEST-PRODUCT",
          quantity: 5
        }],
        shipments: [{
          length: 1,
          width: 1,
          height: 1,
          weight: 1,
          type: "box"
        }],
        options: {
          warehouseRegion: "LAX"
        },
        shipFrom: {
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
  end
end
