# frozen_string_literal: true

class SolidusAdmin::UI::Pages::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  Tab = Struct.new(:text, :href, :current, keyword_init: true)

  # Template methods
  def tabs
  end

  def model_class
  end

  def back_url
  end

  def search_key
  end

  def search_url
  end

  def page_actions
  end

  def sidebar
  end

  def sortable_options
  end

  def row_url(_record)
  end

  def batch_actions
    []
  end

  def scopes
    []
  end

  def filters
    []
  end

  def columns
    []
  end

  # Wraps a geared_pagination page object to provide Kaminari-compatible methods.
  class GearedPaginationProxy < SimpleDelegator
    def current_page
      __getobj__.number
    end

    def first_page?
      current_page == 1
    end

    def last_page?
      __getobj__.last?
    end

    def next_page
      current_page + 1 unless last_page?
    end

    def limit_value
      __getobj__.record_size
    end

    def records
      __getobj__.to_a
    end
  end

  def initialize(page: nil, results: nil)
    if page
      Spree.deprecator.warn(
        "Passing `page:` to #{self.class.name} is deprecated. Pass a Kaminari result as `results:` instead.",
        caller
      )
      @results = GearedPaginationProxy.new(page)
    else
      @results = results
    end
  end

  def row_fade(_record)
    false
  end

  def renderable_tabs
    return unless tabs

    tabs.map { |tab| Tab.new(**tab) }
  end

  def title
    model_class.model_name.human.pluralize
  end

  def search_params
    params[:q]
  end

  def search_name
    :q
  end

  def rows
    @results.records
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @results.current_page - 1, only_path: true) unless @results.first_page?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @results.next_page, only_path: true) unless @results.last_page?
  end

  def search_options
    return unless search_url

    {
      name: search_name,
      value: search_params,
      url: search_url,
      searchbar_key: search_key,
      filters:,
      scopes:
    }
  end

  def render_title
    back_url = self.back_url

    safe_join [
      (page_header_back back_url if back_url),
      page_header_title(title)
    ]
  end

  def render_table
    render component("ui/table").new(
      id: stimulus_id,
      data: {
        class: model_class,
        rows:,
        fade: -> { row_fade(_1) },
        prev: prev_page_path,
        next: next_page_path,
        columns:,
        batch_actions:,
        url: -> { row_url(_1) },
        page: @results.current_page,
        per_page: @results.limit_value
      },
      search: search_options,
      sortable: sortable_options
    )
  end

  def render_sidebar
    sidebar = self.sidebar

    page_with_sidebar_aside { sidebar } if sidebar
  end

  def turbo_frames
    []
  end
end
