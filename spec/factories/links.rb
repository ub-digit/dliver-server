FactoryGirl.define do
  factory :link do
    package_name "MyText"
    link_hash "MyText"
    expire_date Time.now
    note "MyText"
  end
end
