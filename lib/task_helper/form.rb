module TaskHelper
  class Form < Base
    data_member :app_id, :name, :desc, :post_action, :position, :sort_by, :asc,
                :per_page, :allow_delete, :new_widget, :records_widget,
                :target_page, :allow_database, :send_emails, :settings

    def self.all
      Database.all.lazy.flat_map { |db| db.forms }
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

    def initialize(args = {}, database: nil)
      @database = database
      super(args)
    end

    def database
      @database ||= Database.find(app_id)
    end

    def fields
      @fields ||= Field.get(
        route: "apps/#{app_id}/entities/#{id}/properties.json")['fields']
          .map { |field| Field.new(field) }
    end

    def records
      if fields.any?
        @records ||= (1..page_count).lazy.flat_map do |page|
          record_page(page).lazy.map { |record| Record.new(record) }
        end
      end
    end

    private

    def page_count
      database.dtypes_count / per_page + 1
    end

    def record_page(page = 1)
      Record.get(route: "apps/#{app_id}/dtypes/entity/#{id}.json",
                 params: { page: page })['records']
    end
  end
end
