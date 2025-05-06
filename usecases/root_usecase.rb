require 'date'
require 'hitoku'
require 'komeda'
require 'todoist_cms'

class RootUsecase
  class << self
    PROJECT_ID = 2351634984

    def execute
      menus = fetch_menus

      menus.sort_by { |menu| menu[:id].to_i }
    end

    private

    def menu_info
      return @menu_info if @menu_info.present?

      menus_by_category = {
        'スナック' => Komeda.foods,
        'ドリンク' => Komeda.drinks,
        'デザート' => Komeda.desserts
      }

      @menu_info = menus_by_category.each_with_object({}) do |(category, items), hash|
        items.each { |item| hash[item[:id]] = item.merge(category: category) }
      end
    end

    def fetch_menus
      client = TodoistCMS::Client.new(Hitoku.todoist_api_token)
      project = client.project(PROJECT_ID)

      project.items.map { |item| build_item_hash(item) }
    end

    def build_item_hash(item)
      match_data = item.name.match(/(\d+): .*/)
      menu_data = menu_info[match_data[1]]

      menu_data.merge(completed_at: to_jst(item.completed_at)&.to_date)
    end

    def to_jst(completed_at)
      return nil if completed_at.nil?

      Time.parse(completed_at).getlocal('+09:00')
    end
  end
end
