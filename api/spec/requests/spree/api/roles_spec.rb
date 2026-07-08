# frozen_string_literal: true

require "spec_helper"

module Spree::Api
  describe "Roles", type: :request do
    let!(:role_1) { create(:role, name: "customer_service") }
    let!(:role_2) { create(:role, name: "warehouse") }

    let(:attributes) { [:id, :name, :description] }

    before do
      stub_authentication!
    end

    context "as a normal user" do
      it "cannot see the list of roles" do
        get spree.api_roles_path
        expect(json_response["roles"]).to be_empty
      end

      it "cannot see a single role" do
        get spree.api_role_path(role_1.id)
        assert_not_found!
      end

      it "cannot create a new role" do
        post spree.api_roles_path, params: {role: {name: "manager"}}
        assert_unauthorized!
      end

      it "cannot update a role" do
        put spree.api_role_path(role_1.id), params: {role: {name: "renamed"}}
        assert_not_found!
      end

      it "cannot delete a role" do
        delete spree.api_role_path(role_1.id)
        assert_not_found!
        expect { role_1.reload }.not_to raise_error
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can see a list of all roles" do
        get spree.api_roles_path
        # The admin sign-in helper introduces an additional "admin" role.
        expect(json_response["roles"].map { |r| r["name"] }).to include(role_1.name, role_2.name)
        expect(json_response["roles"].first).to have_attributes(attributes)
      end

      it "can control the page size through a parameter" do
        get spree.api_roles_path, params: {per_page: 1}
        expect(json_response["roles"].count).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["per_page"]).to eq(1)
      end

      it "can query the results through a parameter" do
        get spree.api_roles_path, params: {q: {name_cont: "warehouse"}}
        expect(json_response["count"]).to eq(1)
        expect(json_response["roles"].first["name"]).to eq role_2.name
      end

      it "can see a single role" do
        get spree.api_role_path(role_1.id)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["name"]).to eq role_1.name
      end

      it "can create a new role" do
        expect do
          post spree.api_roles_path, params: {role: {name: "manager", description: "Store manager"}}
        end.to change(Spree::Role, :count).by(1)

        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["name"]).to eq("manager")
        expect(json_response["description"]).to eq("Store manager")
      end

      it "cannot create a role with an invalid name" do
        post spree.api_roles_path, params: {role: {name: ""}}
        expect(response.status).to eq(422)
        expect(json_response["errors"]).to have_key("name")
      end

      it "can update a role" do
        put spree.api_role_path(role_1.id), params: {role: {description: "Handles customer service"}}
        expect(response.status).to eq(200)
        expect(role_1.reload.description).to eq("Handles customer service")
      end

      it "can delete a role" do
        delete spree.api_role_path(role_1.id)
        expect(response.status).to eq(204)
        expect { role_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
