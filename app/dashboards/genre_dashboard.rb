require "administrate/base_dashboard"

class GenreDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    icon: Field::String,
    name: Field::String,
    photos: Field::HasMany,
    slug: Field::String,
    # enum用の設定：モデルから選択肢（keys）を取得して状態を
    # 新規追加してもその追加した状態もプルダウンで表示できるようにする
    status: Field::Select.with_options(
      collection: Genre.statuses.keys,
      searchable: false
    ),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    icon
    name
    photos
    status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    icon
    name
    status
    photos
    slug
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    icon
    name
    photos
    slug
    status
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

  # Overwrite this method to customize how genres are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(genre)
  #   "Genre ##{genre.id}"
  # end
  # 管理画面全体で「ジャンル」をどう表示するかを定義。
  # 写真の編集画面などで「どのジャンルか」を選ぶ際に名前が表示されるようにする
   def display_resource(genre)
    genre.name
   end
end
