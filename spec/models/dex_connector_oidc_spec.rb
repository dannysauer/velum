require "rails_helper"

describe DexConnectorOidc, type: :model do
  subject { create(:dex_connector_oidc) }

  it { is_expected.to validate_presence_of(:name) }

  # describe "#configure_dex_oidc_connector" do
  #   let(:dex_connector_oidc) { create(:dex_connector_oidc) }
  # end
end
