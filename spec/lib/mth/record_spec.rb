describe MTH::Record do
  before(:all) { MTH::API.rest_api_key = 'foobar' }
  after(:all) { MTH::API.rest_api_key = nil }

  let(:form) { MTH::Form.all.find(:form_with_fields_needed) { |f| f.fields.any? } }
  let(:data) { FixtureParser.pretty(:records, form.id, form.app_id).sample }
  subject { described_class.new(data.to_h) }

  describe '#form' do
    it 'should return the associated form' do
      expect(subject.form).to eq(form)
    end
  end

  describe '#fields' do
    it 'should return the fields of the associated form' do
      expect(subject.fields).to match_array(form.fields)
    end
  end

  describe '#[]' do
    it 'should return the value of the field with the given name' do
      field = form.fields.sample
      expect(subject[field.name]).to eq(subject.values[field.id])
    end
  end

  describe '#pretty_values' do
    it 'should return the values hashed by field name' do
      result = subject.values.each_with_object({}) do |(k, v), r|
        field = form.fields.find { |f| f.id == k }
        r[field.name] = v
      end
      expect(subject.pretty_values).to eq(result)
    end
  end

  describe 'data members' do
    described_class.data_members.each do |m|
      describe "##{m}" do
        it "should return the value of #{m}" do
          expect(subject.public_send(m)).to eq(data.public_send(m))
        end
      end
    end
  end
end
