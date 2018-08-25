require "base64"

module Velum
  # This class offers the integration between ruby and the Saltstack API.
  module Dex
    class << self
      def oidc_connectors_as_pillar
        oidc_connectors = DexConnectorOidc.all.map do |con|
          {
            "type"          => "oidc",
            "id"            => "oidc-" + con.id.to_s,
            "name"          => con.name,

            "provider_url"  => con.provider_url,
            "client_id"     => con.client_id,
            "client_secret" => con.client_secret,
            "callback_url"  => con.callback_url,
            "basic_auth"    => con.basic_auth
          }
        end
        oidc_connectors
      end
    end
  end
end
