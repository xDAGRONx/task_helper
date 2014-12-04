describe TaskHelper::API::Cache do
  before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
  after(:all) { TaskHelper::API.rest_api_key = nil }

  subject { described_class.new(limit: 2) }

  describe '#get' do
    context 'call already cached' do
      it 'should query the existing call' do
        call1 = TaskHelper::API::Call.new(route: 'hello')
        call2 = TaskHelper::API::Call.new(route: 'hello')
        expect(TaskHelper::API::Call).to receive(:new).with(route: 'hello')
          .twice.and_return(call1, call2)
        expect(call1).to receive(:run).twice
        subject.get(route: 'hello')
        subject.get(route: 'hello')
      end
    end

    context 'call not yet cached' do
      it 'should query a new call' do
        call1 = TaskHelper::API::Call.new(route: 'hello')
        call2 = TaskHelper::API::Call.new(route: 'goodbye')
        expect(call1).to receive(:run).once
        expect(call2).to receive(:run).once
        expect(TaskHelper::API::Call).to receive(:new).once.ordered
          .with(route: 'hello').and_return(call1)
        expect(TaskHelper::API::Call).to receive(:new).once.ordered
          .with(route: 'goodbye').and_return(call2)
        subject.get(route: 'hello')
        subject.get(route: 'goodbye')
      end

      it 'should cache the new call' do
        call1 = TaskHelper::API::Call.new(route: 'hello')
        call2 = TaskHelper::API::Call.new(route: 'goodbye')
        call3 = TaskHelper::API::Call.new(route: 'goodbye')
        expect(call1).to receive(:run).once
        expect(call2).to receive(:run).twice
        expect(TaskHelper::API::Call).to receive(:new).once.ordered
          .with(route: 'hello').and_return(call1)
        expect(TaskHelper::API::Call).to receive(:new).twice.ordered
          .with(route: 'goodbye').and_return(call2, call3)
        subject.get(route: 'hello')
        subject.get(route: 'goodbye')
        subject.get(route: 'goodbye')
      end

      it 'should remove older calls if the limit is reached' do
        call1 = TaskHelper::API::Call.new(route: 'hello')
        call2 = TaskHelper::API::Call.new(route: 'goodbye')
        call3 = TaskHelper::API::Call.new(route: 'foobar')
        call4 = TaskHelper::API::Call.new(route: 'hello')
        expect(call1).to receive(:run).once
        expect(call2).to receive(:run).once
        expect(call3).to receive(:run).once
        expect(call4).to receive(:run).once
        expect(TaskHelper::API::Call).to receive(:new).once.ordered
          .with(route: 'hello').and_return(call1)
        expect(TaskHelper::API::Call).to receive(:new).once.ordered
          .with(route: 'goodbye').and_return(call2)
        expect(TaskHelper::API::Call).to receive(:new).once.ordered
          .with(route: 'foobar').and_return(call3)
        expect(TaskHelper::API::Call).to receive(:new).once.ordered
          .with(route: 'hello').and_return(call4)
        subject.get(route: 'hello')
        subject.get(route: 'goodbye')
        subject.get(route: 'foobar')
        subject.get(route: 'hello')
      end
    end
  end
end
