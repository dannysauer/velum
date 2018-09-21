# Validate that column contains a reachable OIDC Provider
class OidcProviderValidator < HttpUrlValidator
  def self.compliant?(value)
    return false unless super
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
  end

  def validate_each(record, attribute, value)
    return false unless super
    return true if value.present? && self.class.compliant?(value)
    record.errors.add(attribute, "is not a valid OIDC provider")
    false
  rescue SocketError
    record.errors.add(attribute, "is not a valid OIDC provider: bad/unresolvable hostname")
    false # hostname not resolvable
  rescue OpenIDConnect::Discovery::DiscoveryFailed
    record.errors.add(attribute, "is not a valid OIDC provider: discovery failure")
    false # any error with webfinger / issuer mismatch
  rescue HTTPClient::ConnectTimeoutError
    record.errors.add(attribute, "is not a valid OIDC provider: connection timeout")
    false # The System Is Down / StongBad Techno
  end
end
