# Model that represents a dex authentication connector for OIDC
class DexConnectorOidc < ActiveRecord::Base
  self.table_name = "dex_connectors_oidc"

  # should :name have a "uniqueness: true" validation instead?
  validates :name,          presence: true
  # format: { with: /\Asome regex\z/, message: "must match regex" }
  # Maybe /https?:\/\/(user)?(:pass)?@?host(.domain)*(:port)?(\/.*)/
  #
  # Or maybe a validates_with custom validator which attempts the connection?
  # https://guides.rubyonrails.org/active_record_validations.html#validates-with
  # https://stackoverflow.com/a/7167988/65589
  validates :provider_url,  http_url: true, oidc_provider: true
  validates :client_id,     presence: true
  validates :client_secret, presence: true
  validates :callback_url,  http_url: true
  validates :basic_auth,    presence: true
end
