require 'date'
require 'hitoku'

class RootUsecase
  class << self
    PROJECT_ID = 2351634984
    CATEGORY_MAP = { '1-2' => 'ドリンク', '1-3' => 'デザート', '1-4' => 'スナック' }

    def execute
      incomplete_menus = fetch_incomplete_menus
      complete_menus = fetch_complete_menus

      (incomplete_menus + complete_menus).sort_by { |menu| menu[:id].to_i }
    end

    private

    def menu_info
      return @menu_info if @menu_info.present?

      response = Faraday.get('https://eu.komeda.co.jp/v1/hp/menu')
      menus = JSON.parse(response.body, symbolize_names: true)[:menus]

      @menu_info = menus.each_with_object({}) do |item, hash|
        hash[item[:id]] = item
      end
    end

    def client
      @client ||= Todoist::Client.new(Hitoku.todoist_api_token)
    end

    def fetch_incomplete_menus
      response = client.get('/rest/v2/tasks', { project_id: PROJECT_ID })

      response.map { |item| build_item_hash(item) }
    end

    def fetch_complete_menus
      response = client.get('/sync/v9/completed/get_all', { project_id: PROJECT_ID })

      response[:items].map { |item| build_item_hash(item) }
    end

    def build_item_hash(item)
      match_data = item[:content].match(/(\d+): .*/)
      menu_data = menu_info[match_data[1]]

      {
        id: menu_data[:id],
        name: menu_data[:name],
        large_type: menu_data[:large_type],
        category: CATEGORY_MAP[menu_data[:large_type]],
        photo_url: menu_data[:photo_url],
        completed_at: to_jst(item[:completed_at])&.to_date
      }
    end

    def to_jst(completed_at)
      return nil if completed_at.nil?

      Time.parse(completed_at).getlocal('+09:00')
    end
  end
end
