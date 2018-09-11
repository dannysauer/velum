require "rails_helper"

# rubocop:disable RSpec/ExampleLength
# TODO: do we need js?  
#describe "Feature: OIDC connector settings", js: true do
describe "Feature: OIDC connector settings", js: true do
  let!(:user) { create(:user) }
  let!(:dex_connector_oidc) { create(:dex_connector_oidc) }
  let!(:dex_connector_oidc2) { create(:dex_connector_oidc) }
  let!(:dex_connector_oidc3) { create(:dex_connector_oidc) }

  before do
    setup_done
    login_as user, scope: :user
  end

  describe "#index" do
    before do
      visit settings_dex_connector_oidcs_path
    end

    it "allows a user to delete an oidc connector" do
      expect(page).to have_content(dex_connector_oidc.name)
      accept_alert do
        find(".dex_connector_oidc#{dex_connector_oidc.id} .delete-btn").click
      end

      expect(page).to have_content("OIDC Connector was successfully removed.")
      expect(page).not_to have_content(dex_connector_oidc.name)
    end

    it "allows a user to go to an oidc connector's details page" do
      click_link(dex_connector_oidc.name)

      expect(page).to have_current_path(settings_dex_connector_oidc_path(dex_connector_oidc))
    end

    it "allows a user to go to an oidc connector's edit page" do
      find(".dex_connector_oidc#{dex_connector_oidc.id} .edit-btn").click

      expect(page).to have_current_path(edit_settings_dex_connector_oidc_path(dex_connector_oidc))
    end

    it "allows a user to go to the new oidc connector page" do
      click_link("Add OIDC connector")

      expect(page).to have_current_path(new_settings_dex_connector_oidc_path)
    end

    it "lists all the oidc connectors" do
      expect(page).to have_content(dex_connector_oidc.name)
      expect(page).to have_content(dex_connector_oidc2.name)
      expect(page).to have_content(dex_connector_oidc3.name)
    end
  end

  describe "#new" do
    before do
      visit new_settings_dex_connector_oidc_path
    end

    it "allows a user to create an oidc connector" do
      # TODO: figure out remaining fields
      #fill_in id: "dex_connector_oidc_name", with: "test oidc"
      #fill_in "Host", with: "oidctest.com"

      VCR.use_cassette("oidc/validate_connector", record: :none) do
        click_button("Validate")
        click_button("Save")
        last_oidc_connector = DexConnectorOidc.last
        expect(page).to have_content("DexConnectorOidc was successfully created.")
        expect(page).to have_current_path(settings_dex_connector_oidc_path(last_oidc_connector))
      end
    end

    # TODO: verify each field fails on empty?
    # it "shows an error message for empty fields" do
    # it "shows an error message for unresolvable issuer host" do
    it "shows an error message for non-http issuer" do
      fill_in "Port", with: "AAA"
      fill_in "Password", with: "pass"
      fill_in "Identifying User Attribute", with: "pass"
      fill_in id: "dex_connector_oidc_bind_dn", with: "cn=admin,dc=oidctest,dc=com"
      fill_in id: "dex_connector_oidc_bind_pw", with: "pass"

      page.execute_script("$('#oidc_conn_save').removeProp('disabled')")
      click_button("Save")
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Host can't be blank")
      expect(page).to have_content("Port is not a number")
    end

  end

# describe "#edit" do
#   before do
#     visit edit_settings_dex_connector_oidc_path(dex_connector_oidc)
#   end
#
#   it "allows a user to edit an oidc connector" do
#     fill_in "Port", with: 626
#     attach_file "Certificate", admin_cert_file.path
#     page.execute_script("$('#oidc_conn_save').removeProp('disabled')")
#     click_button("Save")
#
#     expect(page).to have_content("DexConnectorOidc was successfully updated.")
#   end
#
#   it "shows an error message if model validation fails" do
#     fill_in "Port", with: "AAA"
#     attach_file "Certificate", admin_cert_file.path
#     page.execute_script("$('#oidc_conn_save').removeProp('disabled')")
#     click_button("Save")
#
#     expect(page).to have_content("Port is not a number")
#   end
# end

  describe "#show" do
    before do
      visit settings_dex_connector_oidc_path(dex_connector_oidc)
    end

    it "allows a user to delete an oidc connector" do
      accept_alert do
        click_on("Delete")
      end

      expect(page).not_to have_content(dex_connector_oidc.name)
      expect(page).to have_content("OIDC Connector was successfully removed.")
      expect(page).to have_current_path(settings_dex_connector_oidcs_path)
    end

    it "allows a user to go to an oidc connector's edit page" do
      click_on("Edit")

      expect(page).to have_current_path(edit_settings_dex_connector_oidc_path(dex_connector_oidc))
    end
  end
end
# rubocop:enable RSpec/ExampleLength
