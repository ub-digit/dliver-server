require 'rails_helper'

RSpec.describe Link, type: :model do
  describe "create" do
    it {should validate_presence_of(:package_name)}
    it {should validate_presence_of(:link_hash)}
    it {should validate_presence_of(:expire_date)}
  end

  describe "hash generation" do
    it "should generate link" do
      package_name = "GUB0100143"
      expire_date = Time.now + 2.days
      
      link = Link.generate(package_name, expire_date)
      expect(link.save).to be_truthy
      # Result of SecureRandom.uuid
      expect(link.link_hash).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    end
  end
  
  describe "hash validation" do
    context "valid expire date" do
      it "should be fine with a valid hash" do
        package_name = "GUB0100143"
        expire_date = Time.now + 2.days
        
        link = Link.generate(package_name, expire_date)
        expect(link.save).to be_truthy
      end
    end

    context "invalid expire date" do
      it "should fail with an invalid hash" do
        package_name = "GUB0100143"
        expire_date = Time.now - 2.days
        
        link = Link.generate(package_name, expire_date)
        expect(link.save).to be_falsey
      end
    end
  end
end
