# frozen_string_literal: true

module Spree
  module Api
    class RolesController < Spree::Api::BaseController
      def index
        @roles = Spree::Role
          .accessible_by(current_ability)
          .order("name ASC")
          .ransack(params[:q])
          .result

        @roles = paginate(@roles)

        respond_with(@roles)
      end

      def show
        respond_with(role)
      end

      def create
        authorize! :create, Spree::Role
        @role = Spree::Role.new(role_params)
        if @role.save
          respond_with(@role, status: 201, default_template: :show)
        else
          invalid_resource!(@role)
        end
      end

      def update
        authorize! :update, role
        if role.update(role_params)
          respond_with(role, status: 200, default_template: :show)
        else
          invalid_resource!(role)
        end
      end

      def destroy
        authorize! :destroy, role
        role.destroy
        respond_with(role, status: 204)
      end

      private

      def role_params
        params.require(:role).permit(:name, :description, permission_set_ids: [])
      end

      def role
        @role ||= Spree::Role.accessible_by(current_ability, :show).find(params[:id])
      end
    end
  end
end
