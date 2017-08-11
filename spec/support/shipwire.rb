RSpec.configure do |config|
  config.before :each do
    Shipwire.configure do |c|
      c.username = ENV['USERNAME']
      c.password = ENV['PASSWORD']
      c.endpoint = ENV['ENDPOINT'] || "https://api.beta.shipwire.com"
      c.logger   = false
    end
  end
end
