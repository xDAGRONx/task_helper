module FixtureParser
  module_function

  def databases
    parse_file('databases')['databases']
  end

  def database(id)
    databases.find { |db| db['id'] == id }
  end

  def forms(database = nil)
    if database
      parse_file("databases/#{database}/forms")['forms']
    else
      databases.flat_map do |db|
        parse_file("databases/#{db['id']}/forms")['forms']
      end
    end
  end

  def form(id, database = nil)
    forms(database).find { |f| f['id'] == id }
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
