require "rails_helper"

RSpec.describe Settings::DexConnectorOidcsController, type: :controller do
  let(:user) { create(:user) }

  before do
    setup_done
    sign_in user
  end

  describe "GET #index" do
    let!(:connector) do
      VCR.use_cassette("oidc/validate_connector", allow_playback_repeats: true, record: :none) do
        create(:dex_connector_oidc)
      end
    end

    before do
      get :index
    end

    it "populates an array of oidc dex connectors" do
      expect(assigns(:oidc_connectors)).to match_array([connector])
    end
  end

  # describe "GET #new" do
  #   before do
  #     get :new
  #   end

  #   it "assigns a new oidc dex connector to @certificate_holder" do
  #     expect(assigns(:certificate_holder)).to be_a_new(DexConnectorOidc)
  #   end

  #   it "assigns a new certificate to @cert" do
  #     expect(assigns(:cert)).to be_a_new(Certificate)
  #   end
  # end

  describe "GET #edit" do
    let!(:connector) do
      VCR.use_cassette("oidc/validate_connector", allow_playback_repeats: true, record: :none) do
        create(:dex_connector_oidc)
      end
    end

    before do
      get :edit, id: connector.id
    end

    it "assigns dex_connector_oidc to @dex_connector_oidc" do
      expect(assigns(:dex_connector_oidc)).not_to be_a_new(DexConnectorOidc)
    end

    it "return 404 if oidc connector does not exist" do
      get :edit, id: DexConnectorOidc.last.id + 1
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    # rubocop:disable RSpec/ExampleLength
    # TODO: can the post be moved out to a let() and still work?
    it "can not save oidc connector with invalid field" do
      VCR.use_cassette("oidc/validate_connector", allow_playback_repeats: true, record: :none) do
        expect do
          post :create, dex_connector_oidc: { name: "oidc_fail", invalid_whatevz: nil }
        end.not_to change(DexConnectorOidc, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    # rubocop:enable RSpec/ExampleLength

    context "with oidc connector saved in the database" do
      let!(:connector) do
        VCR.use_cassette("oidc/validate_connector", allow_playback_repeats: true, record: :none) do
          post :create, dex_connector_oidc: { name:          "oidc1",
                                              provider_url:  "http://your.fqdn.here:5556/dex",
                                              callback_url:  "http://some.fqdn.here/callback",
                                              basic_auth:    true,
                                              client_id:     "client",
                                              client_secret: "secret_string" }

        end
        DexConnectorOidc.find_by(name: "oidc1")
      end

      it "saves the correct name" do
        expect(connector.name).to eq("oidc1")
      end
      it "saves the correct provider_url" do
        expect(connector.provider_url).to eq("http://your.fqdn.here:5556/dex")
      end
      it "saves the correct callback_url" do
        expect(connector.callback_url).to eq("http://some.fqdn.here/callback")
      end
      it "saves the correct client_id" do
        expect(connector.client_id).to eq("client")
      end
      it "saves the correct client_secret" do
        expect(connector.client_secret).to eq("secret_string")
      end
      it "saves the correct basic_auth value" do
        expect(connector.basic_auth).to eq(true)
      end
    end
  end

  describe "PATCH #update" do
    let!(:connector) do
      VCR.use_cassette("oidc/validate_connector", allow_playback_repeats: true, record: :none) do
        create(:dex_connector_oidc)
      end
    end

    it "updates an oidc connector" do
      VCR.use_cassette("oidc/validate_connector", allow_playback_repeats: true, record: :none) do
        dex_connector_oidc_params = { name: "new name" }
        put :update, id: connector.id, dex_connector_oidc: dex_connector_oidc_params
        expect(DexConnectorOidc.find(connector.id).name).to eq("new name")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:connector) do
      VCR.use_cassette("oidc/validate_connector", allow_playback_repeats: true, record: :none) do
        create(:dex_connector_oidc)
      end
    end

    it "deletes an oidc connector" do
      expect do
        delete :destroy, id: connector.id
      end.to change(DexConnectorOidc, :count).by(-1)
    end
  end
end
