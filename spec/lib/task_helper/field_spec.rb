describe TaskHelper::Field do
  before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
  after(:all) { TaskHelper::API.rest_api_key = nil }

  describe '#form' do
    it 'should return the associated form' do
      field = described_class.new(FixtureParser.fields.sample)
      expect(field.form).to be_a(TaskHelper::Form)
      expect(field.form.id).to eq(field.entity_id)
    end
  end

  describe 'data members' do
    described_class.data_members.each do |m|
      describe "##{m}" do
        it "should return the value of #{m}" do
          field = described_class.new(FixtureParser.fields.sample)
          data = FixtureParser.pretty(:field, field.id, field.entity_id)
          expect(field.public_send(m)).to eq(data.send(m))
        end
      end
    end
  end
end
