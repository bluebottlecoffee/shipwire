require 'spec_helper'

RSpec.describe "Stock", type: :feature, vcr: true do
  context "list" do
    context "without params" do
      it "is successful" do
        VCR.use_cassette("stock_without_params") do
          response = Shipwire::Stock.list

          expect(response.ok?).to be_truthy
        end
      end
    end

    context "with params" do
      it "is successful" do
        VCR.use_cassette("stock_with_params") do
          response = Shipwire::Stock.list(
            sku: "TEST-PRODUCT"
          )

          expect(response.ok?).to be_truthy
        end
      end
    end

    context "with params and non-existant SKU" do
      it "is successful" do
        # Returns a successful result. There is just no records in the result
        # set because they were all filtered out. There are no errors.
        VCR.use_cassette("stock_with_params_no_sku") do
          response = Shipwire::Stock.list(
            sku: "FAKE-PRODUCT"
          )

          expect(response.ok?).to be_truthy
        end
      end
    end
  end
end
