require 'sinatra/base'

class FakeMTH < Sinatra::Base
  get '/apps.json' do
    json_response(200, 'databases')
  end

  get '/apps/search.json' do
    search = string_params
    result = databases.find { |d| d.merge(search) == d }
    { 'database' => result }.to_json if result
  end

  get '/apps/:id.json' do
    result = databases.find { |d| d['id'] == params[:id] }
    { 'database' => result }.to_json if result
  end

  private

  def string_params
    params.each_with_object({}) do |(k, v), result|
      result[k.to_s] = v unless k.to_s == 'rest_api_key'
    end
  end

  def databases
    JSON.parse(json_response(200, 'databases'))['databases']
  end

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open("#{File.dirname(__FILE__)}/fixtures/#{file_name}.json").read
  end
end