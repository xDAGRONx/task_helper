require 'sinatra/base'

class FakeMTH < Sinatra::Base
  get '/apps/search.json' do
    search = string_params
    result = databases.find { |d| d.merge(search) == d }
    content_type :json
    status 200
    { 'database' => result }.to_json if result
  end

  get '/apps/:id.json' do
    result = databases.find { |d| d['id'] == params[:id] }
    content_type :json
    status 200
    { 'database' => result }.to_json if result
  end

  get '/apps.json' do
    json_response(200, 'databases')
  end

  get '/apps/search/entities/search.json' do
    content_type :json
    status 200
    if db = databases.find { |d| d['name'] == params[:database_name] }
      result = forms(db['id']).find { |f| f['name'] == params[:form_name] }
      { 'form' => result }.to_json if result
    end
  end

  get '/apps/:db_id/entities/:form_id.json' do
    result = forms(params[:db_id]).find { |f| f['id'] == params[:form_id] }
    content_type :json
    status 200
    { 'form' => result }.to_json if result
  end

  get '/apps/:db_id/entities.json' do
    result = forms(params[:db_id])
    content_type :json
    status 200
    { 'forms' => result }.to_json if result
  end

  get '/apps/:db_id/entities/:form_id/properties.json' do
    result = FixtureParser.fields(params[:form_id], params[:db_id])
    content_type :json
    status 200
    { 'fields' => result }.to_json if result
  end

  get '/apps/:db_id/dtypes/:id.json' do
    forms = FixtureParser.forms(params[:db_id])
    record = nil
    forms.each do |form|
      records = (1...Float::INFINITY).lazy
        .map { |n| FixtureParser.records(form['id'], form['app_id'], n) }
        .take_while { |r| !r.nil? }
        .flat_map { |r| r }
      break if (record = records.find { |r| r['id'] == params[:id] })
    end
    content_type :json
    status 200
    { 'record' => record }.to_json if record
  end

  get '/apps/:db_id/dtypes/entity/:form_id.json' do
    json_response(200, "databases/#{params[:db_id]}/forms/" \
      "#{params[:form_id]}/records/#{params[:page]}")
  end

  private

  def string_params
    params.each_with_object({}) do |(k, v), result|
      result[k.to_s] = v unless k.to_s == 'rest_api_key'
    end
  end

  def forms(database_id)
    if databases.any? { |db| db['id'] == database_id }
      JSON.parse(json_response(200,
        "databases/#{database_id}/forms"))['forms']
    else
      []
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
