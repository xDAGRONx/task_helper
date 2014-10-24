module MTH
  class Form < Base
    data_member :app_id, :name, :desc, :post_action, :position, :sort_by, :asc,
                :per_page, :allow_delete, :new_widget, :records_widget,
                :target_page, :allow_database, :send_emails, :settings

    def self.all
      Database.all.flat_map { |db| db.forms }
    end

    def self.find_by(search)
      if response = get(route: 'apps/search/entities/search.json', params: search)
        new response['form'] if response['form']
      end
    end

    def self.find(database:, form:)
      if response = get(route: "apps/#{database}/entities/#{form}.json")
        new response['form'] if response['form']
      end
    end

    def database
      @database ||= Database.find(app_id)
    end
  end
end
