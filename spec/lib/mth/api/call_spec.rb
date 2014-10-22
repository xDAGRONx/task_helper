describe MTH::API::Call do
  let(:key) { { rest_api_key: 'foobar' } }
  let(:response) { double(parsed_response: [{ 'a' => 1 }]) }

  it 'should define a reader for time' do
    t = Time.now
    args = { route: 'hello', params: key, time: t }
    expect(described_class.new(args).time).to eq(t)
  end

  describe '.new' do
    context 'given an api key' do
      subject { described_class.new(route: 'hello', params: key) }

      it 'should not raise a missing key error' do
        expect { subject }.not_to raise_exception
      end

      it 'should replace the default key' do
        MTH::API.rest_api_key = 'hello'
        expect(HTTParty).to receive(:get)
          .with(anything, key).and_return(response)
        subject.run
        MTH::API.rest_api_key = nil
      end
    end

    context 'without an api key' do
      subject { described_class.new(route: 'hello') }

      it 'should attempt to use the default' do
        MTH::API.rest_api_key = 'hello'
        expect(HTTParty).to receive(:get)
          .with(anything, { rest_api_key: 'hello' }).and_return(response)
        subject.run
        MTH::API.rest_api_key = nil
      end

      it 'should raise an exception if no default is set' do
        expect { subject }.to raise_exception(MTH::API::Call::MissingAPIKey)
      end
    end
  end

  describe '#run' do
    before(:all) { MTH::API.rest_api_key = 'foobar' }
    after(:all) { MTH::API.rest_api_key = nil }

    subject { described_class.new(route: 'hello') }

    it 'should reset the time' do
      expect { subject.run }.to change { subject.time }
    end

    it 'should make a request to the given route at mytaskhelper.com' do
      expect(HTTParty).to receive(:get)
        .with('https://mytaskhelper.com/hello', { rest_api_key: 'foobar' })
        .and_return(response)
      subject.run
    end

    context 'call has expired' do
      it 'should resend the request' do
        params = { route: 'hello', timeout: 0 }
        call = described_class.new(params)
        expect(HTTParty).to receive(:get).twice.and_return(response)
        call.run
        call.run
      end
    end

    context 'call has not expired' do
      context 'request has been cached' do
        it 'should return the cached response' do
          expect(HTTParty).to receive(:get).once.and_return(response)
          result = subject.run
          expect(subject.run).to eq(result)
        end
      end

      context 'request has not been chached' do
        it 'should retrieve the response' do
          expect(HTTParty).to receive(:get).once.and_return(response)
          expect(subject.run).to eq(response.parsed_response)
        end
      end
    end
  end

  describe '#expired?' do
    before(:all) { MTH::API.rest_api_key = 'foobar' }
    after(:all) { MTH::API.rest_api_key = nil }

    context 'request timed out' do
      it 'shoud return false' do
        args = { route: 'hello', timeout: 0, time: Time.now - 5 }
        expect(described_class.new(args).expired?).to be(true)
      end
    end

    context 'request not timed out' do
      it 'shoud return false' do
        args = { route: 'hello', timeout: 100, time: Time.now - 5 }
        expect(described_class.new(args).expired?).to be(false)
      end
    end
  end

  describe '#==' do
    before(:all) { MTH::API.rest_api_key = 'foobar' }
    after(:all) { MTH::API.rest_api_key = nil }

    subject { described_class.new(route: 'hello', params: { a: 1 }) }

    context 'route does not match' do
      it 'should return false' do
        expect(subject == described_class.new(route: 'hi'))
          .to be(false)
      end
    end

    context 'args do not match' do
      it 'should return false' do
        expect(subject == described_class.new(route: 'hello', params: { b: 2 }))
          .to be(false)
      end
    end

    context 'route and args match' do
      it 'should return true' do
        expect(subject == described_class.new(route: 'hello', params: { a: 1 }))
          .to be(true)
      end
    end
  end
end
