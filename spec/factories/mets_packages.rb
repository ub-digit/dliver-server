FactoryGirl.define do
  factory :mets_package do
    search_string "dummy"
    trait :libris_xml do
      xml File.new("#{Rails.root}/spec/fixtures/102377_libris_mets.xml").read
    end

    trait :libris_nonsort_xml do
      xml File.new("#{Rails.root}/spec/fixtures/102377_libris_mets_w_nonsort.xml").read
    end

    trait :document_xml do
      xml File.new("#{Rails.root}/spec/fixtures/102421_document_mets.xml").read
    end

    trait :letter_xml do
      xml File.new("#{Rails.root}/spec/fixtures/104358_letter_mets.xml").read
    end

    trait :dc_xml do
      xml File.new("#{Rails.root}/spec/fixtures/99999_dc_mets.xml").read
    end

    trait :empty_xml do
      xml nil
    end

    factory :mets_package_empty, traits: [:empty_xml]
    factory :libris_package, traits: [:libris_xml]
    factory :libris_nonsort_package, traits: [:libris_nonsort_xml]
    factory :document_package, traits: [:document_xml]
    factory :letter_package, traits: [:letter_xml]
    factory :dc_package, traits: [:dc_xml]
  end
end
