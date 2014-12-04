describe TaskHelper::API do
  subject { TaskHelper::API }

  it 'should define a singleton accessor for "rest_api_key"' do
    expect(subject.rest_api_key).to eq(nil)
    expect { subject.rest_api_key = 'foobar' }
      .to change { subject.rest_api_key }.from(nil).to('foobar')
  end

  describe '.get' do
    before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
    after(:all) { TaskHelper::API.rest_api_key = nil }

    it 'should forward to the cache' do
      expect_any_instance_of(TaskHelper::API::Cache).to receive(:get)
        .with(route: 'hello')
      subject.get(route: 'hello')
    end
  end

  describe '.set_cache' do
    before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
    after(:all) { TaskHelper::API.rest_api_key = nil }

    it 'should reset the cache to a new instance with the given arguments' do
      cache = TaskHelper::API::Cache.new(limit: 2)
      expect(TaskHelper::API::Cache).to receive(:new).with(limit: 2)
        .and_return(cache)
      subject.set_cache(limit: 2)
      expect(cache).to receive(:get).with(route: 'hello')
      subject.get(route: 'hello')
    end
  end

  describe '.extended' do
    before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
    after(:all) { TaskHelper::API.rest_api_key = nil }

    it 'should set the cache for the class' do
      test = Class.new
      expect(test).to receive(:set_cache)
      test.extend(subject)
    end
  end
end
