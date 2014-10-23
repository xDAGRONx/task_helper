module FixtureParser
  module_function

  def databases
    parse_file('databases')['databases']
  end

  def database(id)
    databases.find { |db| db['id'] == id }
  end

  private

  module_function

  def parse_file(file_name)
    JSON.parse(File
      .open("#{File.dirname(__FILE__)}/fixtures/#{file_name}.json").read)
  end
end
