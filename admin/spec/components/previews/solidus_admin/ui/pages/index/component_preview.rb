# frozen_string_literal: true

# @component "ui/pages/index"
class SolidusAdmin::UI::Pages::Index::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    results = Spree::Order.page(1)

    component_subclcass = Class.new(component("ui/pages/index")) do
      def self.name
        "SolidusAdmin::MyIndex::Component"
      end

      def prev_page_path
        nil
      end

      def next_page_path
        nil
      end

      def model_class
        Spree::Order
      end

      def search_key
        :number_cont
      end

      def search_url
        "/admin/orders"
      end

      def columns
        [:number]
      end

      def page_actions
        render component("ui/button").new(
          tag: :a,
          text: t(".add"),
          href: spree.new_admin_order_path,
          icon: "add-line"
        )
      end

      def batch_actions
        [{
          label: "Print",
          action: "print"
        }]
      end
    end

    render component_subclcass.new(results:)
  end

  # @label With filters, scopes, and pagination
  def with_filters_scopes_and_pagination
      results = Spree::Product.page(1).limit(5)

      component_subclass = Class.new(component("ui/pages/index")) do
        def self.name
          "SolidusAdmin::MyProductIndex::Component"
        end

        # def prev_page_path
        #   nil
        # end
        #
        # def next_page_path
        #   "/?page=2"
        # end

        def model_class
          Spree::Product
        end

        def search_key
          :name_cont
        end

        def search_url
          "/admin/products"
        end

        def columns
          [:name, :available_on, :slug]
        end

        def scopes
          [
            { name: :all, label: "All", default: true },
            { name: :in_stock, label: "In Stock" },
            { name: :out_of_stock, label: "Out of Stock" },
            { name: :available, label: "Available" },
            { name: :discontinued, label: "Discontinued" }
          ]
        end

        def filters
          [
            {
              label: "Status",
              combinator: "or",
              attribute: "status",
              predicate: "eq",
              options: [
                %w[Available available],
                %w[Discontinued discontinued],
                %w[Draft draft]
              ]
            },
            {
              label: "Price Range",
              combinator: "or",
              attribute: "master_price",
              predicate: "gteq",
              options: [
                ["Under $25", 0],
                ["$25 - $50", 25],
                ["$50 - $100", 50],
                ["Over $100", 100]
              ]
            }
          ]
        end

        def tabs
          [
            { text: "Products", href: "/admin/products", current: true },
            { text: "Option Types", href: "/admin/option_types", current: false },
            { text: "Properties", href: "/admin/properties", current: false }
          ]
        end

        def page_actions
          render component("ui/button").new(
            tag: :a,
            text: "Add Product",
            href: "/admin/products/new",
            icon: "add-line"
          )
        end

        def batch_actions
          [
            { label: "Activate", action: "activate" },
            { label: "Discontinue", action: "discontinue" },
            { label: "Delete", action: "delete" }
          ]
        end
      end

      render component_subclass.new(results:)
    end
end
