FactoryGirl.define do
  factory :mets_package do
    libris_xml
  
    trait :libris_xml do
      xml File.new("#{Rails.root}/spec/fixtures/102377_libris_mets.xml").read
    end
  end

end
