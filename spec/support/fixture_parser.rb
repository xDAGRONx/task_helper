module FixtureParser
  module_function

  def databases
    parse_file('databases')['databases']
  end

  def database(id)
    databases.find { |db| db['id'] == id }
  end

  def forms(database_id = nil)
    if database_id.nil?
      databases.flat_map do |db|
        parse_file("databases/#{db['id']}/forms")['forms']
      end
    elsif database(database_id)
      parse_file("databases/#{database_id}/forms")['forms']
    else
      []
    end
  end

  def form(id, database_id = nil)
    forms(database_id).find { |f| f['id'] == id }
  end

  def fields(form_id = nil, database_id = nil)
    if form_id.nil?
      forms(database_id).flat_map do |form|
        parse_file("databases/#{form['app_id']}/forms/#{form['id']}/fields")['fields']
      end
    elsif form = form(form_id, database_id)
      parse_file("databases/#{form['app_id']}/forms/#{form_id}/fields")['fields']
    else
      []
    end
  end

  def field(id, form_id = nil, database_id = nil)
    fields(form_id, database_id).find { |f| f['id'] == id }
  end

  def pretty(method_name, *args)
    case result = public_send(method_name, *args)
    when Array
      result.map { |e| OpenStruct.new(e) }
    when Hash
      OpenStruct.new(result)
    else
      result
    end
  end

  private

  module_function

  def parse_file(file_name)
    JSON.parse(File
      .open("#{File.dirname(__FILE__)}/fixtures/#{file_name}.json").read)
  end
end
