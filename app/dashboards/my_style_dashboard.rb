require "administrate/base_dashboard"

class MyStyleDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    analysis_result: Field::BelongsTo,
    custom_name: Field::String,
    genre: Field::BelongsTo,
    my_style_selections: Field::HasMany,
    photos: Field::HasMany,
    public_token: Field::String,
    selected_photos: Field::HasMany,
    selected_selections: Field::HasMany,
    style_type: Field::Number,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    analysis_result
    custom_name
    genre
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    analysis_result
    custom_name
    genre
    my_style_selections
    photos
    public_token
    selected_photos
    selected_selections
    style_type
    user
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    analysis_result
    custom_name
    genre
    my_style_selections
    photos
    public_token
    selected_photos
    selected_selections
    style_type
    user
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how my styles are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(my_style)
  #   "MyStyle ##{my_style.id}"
  # end
end
