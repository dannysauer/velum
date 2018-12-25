require "rails_helper"

# rubocop:disable RSpec/ExampleLength
describe "Feature: External Cerificate settings", js: true do
  let!(:user) { create(:user) }

  # let(:ssl_cert_file_a) { file_fixture("ext_cert_ssl_a.pem").read } # TODO:  Make file
  # let(:ssl_key_file_a) { file_fixture("ext_cert_key_a.pem").read } # TODO:  Make file
  # let(:ssl_cert_file_b) { file_fixture("ext_cert_ssl_b.pem").read } # TODO:  Make file
  # let(:ssl_key_file_b) { file_fixture("ext_cert_key_b.pem").read } # TODO:  Make file
  # let(:ssl_cert_file_malformed) { file_fixture("ext_cert_ssl_mal.pem").read } # TODO:  Make file
  # let(:ssl_key_file_malformed) { file_fixture("ext_cert_key_mal.pem").read } # TODO:  Make file

  before do
    setup_done
    login_as user, scope: :user
  end

  describe "#index" do
    before do
      visit settings_ext_cert_index_path
    end

    # Success Conditions

    it "sucessfully uploads velum cert/key" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:success)
      # expect(page).to have_content(file_fixture("ext_cert_ssl_a.pem").read)  # Change to parsed cert details
      expect(page).to have_content("External Certificate settings successfully saved.", wait: 3)
    end

    it "sucessfully uploads kubeAPI cert/key" do
      attach_file "external_certificate_kubeapi_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_kubeapi_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:success)
      # expect(page).to have_content(file_fixture("ext_cert_ssl_a.pem").read)  # Change to parsed cert details
      expect(page).to have_content("External Certificate settings successfully saved.", wait: 3)
    end

    it "sucessfully uploads dex cert/key" do
      attach_file "external_certificate_dex_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_dex_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:success)
      # expect(page).to have_content(file_fixture("ext_cert_ssl_a.pem").read)  # Change to parsed cert details
      expect(page).to have_content("External Certificate settings successfully saved.", wait: 3)
    end

    it "sucessfully uploads velum, kubeAPI, and dex cert/key" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"
      attach_file "external_certificate_kubeapi_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_kubeapi_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"
      attach_file "external_certificate_dex_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_dex_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:success)
      # expect(page).to have_content(file_fixture("ext_cert_ssl_a.pem").read)  # Change to parsed cert details
      expect(page).to have_content("External Certificate settings successfully saved.", wait: 3)
    end

    # Faiure Conditions

    it "uploads malformed velum certificate" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_mal.pem"
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Invalid Velum certificate, check format and try again", wait: 3)
    end

    it "uploads malformed velum key" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_mal.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Invalid Velum key, check format and try again.", wait: 3)
    end

    it "uploads malformed kubeAPI certificate" do
      attach_file "external_certificate_kubeapi_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_mal.pem"
      attach_file "external_certificate_kubeapi_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Invalid Kubernetes API certificate, check format and try again", wait: 3)
    end

    it "uploads malformed kubeAPI key" do
      attach_file "external_certificate_kubeapi_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_kubeapi_key", RSpec.configuration.fixture_path + "/ext_cert_key_mal.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Invalid Kubernetes API key, check format and try again.", wait: 3)
    end

    it "uploads malformed dex certificate" do
      attach_file "external_certificate_dex_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_mal.pem"
      attach_file "external_certificate_dex_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Invalid Dex certificate, check format and try again", wait: 3)
    end

    it "uploads malformed dex key" do
      attach_file "external_certificate_dex_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_dex_key", RSpec.configuration.fixture_path + "/ext_cert_key_mal.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Invalid Dex key, check format and try again.", wait: 3)
    end

    it "uploads only velum certificate" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Error with Velum, certificate and key must be uploaded together.", wait: 3)
    end

    it "uploads only velum key" do
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Error with Velum, certificate and key must be uploaded together.", wait: 3)
    end

    it "uploads only velum, kubeAPI, and dex certificates" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_kubeapi_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_dex_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Error with Velum, certificate and key must be uploaded together.", wait: 3)
    end

    it "uploads only velum, kubeAPI, and dex keys" do
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"
      attach_file "external_certificate_kubeapi_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"
      attach_file "external_certificate_dex_key", RSpec.configuration.fixture_path + "/ext_cert_key_a.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Error with Velum, certificate and key must be uploaded together.", wait: 3)
    end

    it "uploads mismatched velum cert/key" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_b.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Certificate/Key pair invalid.  Ensure Certificate and Key are matching.", wait: 3)
    end

    it "uploads mismatched velum, kubeAPI, and dex cert/key" do
      attach_file "external_certificate_velum_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_velum_key", RSpec.configuration.fixture_path + "/ext_cert_key_b.pem"
      attach_file "external_certificate_kubeapi_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_kubeapi_key", RSpec.configuration.fixture_path + "/ext_cert_key_b.pem"
      attach_file "external_certificate_dex_cert", RSpec.configuration.fixture_path + "/ext_cert_ssl_a.pem"
      attach_file "external_certificate_dex_key", RSpec.configuration.fixture_path + "/ext_cert_key_b.pem"

      click_button("Save")
      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_content("Certificate/Key pair invalid.  Ensure Certificate and Key are matching.", wait: 3)
    end
  end
end
# rubocop:enable RSpec/ExampleLength
