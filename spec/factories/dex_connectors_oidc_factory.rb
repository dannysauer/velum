FactoryGirl.define do
  factory :dex_connector_oidc, class: DexConnectorOidc do
    sequence(:name) { |n| "OIDC Server #{n}" }
    provider_url "http://your.fqdn.here:5556/dex"
    callback_url "http://fake.host" # needed for database cleaner :/
    client_id "example-app"
    client_secret "ZXhhbXBsZS1hcHAtc2VjcmV0"
    basic_auth true
  end
end
