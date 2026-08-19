# frozen_string_literal: true

module SolidusAdmin
  class OptionTypesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search
    include SolidusAdmin::Moveable

    def index
      option_types = apply_search_to(
        Spree::OptionType.all,
        param: :q
      )

      option_types = option_types.page(params[:page]).without_count

      respond_to do |format|
        format.html { render component("option_types/index").new(results: option_types) }
      end
    end

    def destroy
      @option_types = Spree::OptionType.where(id: params[:id])

      Spree::OptionType.transaction { @option_types.destroy_all }

      flash[:notice] = t(".success")
      redirect_back_or_to option_types_path, status: :see_other
    end
  end
end
