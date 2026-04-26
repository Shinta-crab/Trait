require "administrate/base_dashboard"

class PhotoDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    genre: Field::BelongsTo,
    # この Gem の機能（プレビュー等）をフル活用します
    image: Field::ActiveStorage.with_options(
      show_display_preview: true,
      index_display_preview: true,
      index_preview_size: [100, 100],
      show_preview_size: [400, 400]
    ),
    photo_scores: Field::HasMany, 
    is_representative: Field::Boolean,
    main_style: Field::BelongsTo,
    likes: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    image_path: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    image
    genre
    is_representative
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    image
    genre
    is_representative
    main_style
    photo_scores
    likes
    image_path
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    genre
    image
    is_representative
    main_style
    photo_scores
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

  # Overwrite this method to customize how photos are displayed
  # across all pages of the admin dashboard.
  #
   # リソースの表示名（他画面でのセレクトボックス等用）
  def display_resource(photo)
    "Photo ##{photo.id}" #(#{photo.genre.name})"
  end
end
