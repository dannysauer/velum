# Validate that column contains a reachable OIDC Provider
class OidcProviderValidator < ActiveModel::EachValidator
  # TODO: take record as a parameter, and add appropriate error on validation steps
  #       ...or create specific exceptions that can be caught?
  # currently, just returns true/false, so all failures result in the same message
  def self.compliant?(value)
    parsed_uri = URI.parse(value)
    unless parsed_uri.is_a?(URI::HTTPS)
      # SWD will be replaced with Webfinger in OIDC gem eventually.
      # Setting both here should help future-proof things
      SWD.url_builder = URI::HTTP
      WebFinger.url_builder = URI::HTTP
    end
    ## value should be the issuer
    response = OpenIDConnect::Discovery::Provider::Config.discover!(value)
    ## validate method compares issuer to expected issuer
    response.validate(value)
    # TODO: also check supported methods?
  rescue SocketError
    false # hostname not resolvable
  rescue OpenIDConnect::Discovery::DiscoveryFailed
    false # any error with webfinger / issuer mismatch
  rescue URI::InvalidURIError
    false # malformed URL
  end

  def validate_each(record, attribute, value)
    return true if value.present? && self.class.compliant?(value)
    record.errors.add(attribute, "is not a valid OIDC provider")
    false
  end
end
