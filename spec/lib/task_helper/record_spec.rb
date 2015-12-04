describe TaskHelper::Record do
  before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
  after(:all) { TaskHelper::API.rest_api_key = nil }

  let(:form) { TaskHelper::Form.all.find(:form_with_fields_needed) { |f| f.fields.any? } }
  let(:data) { FixtureParser.pretty(:records, form.id, form.app_id).sample }
  subject { described_class.new(data.to_h) }

  describe '::find' do
    it 'should find the record with the given ID' do
      record = form.records.first
      expect(described_class.find(record.id, database_id: form.app_id))
        .to eq(record)
    end

    context 'database or record not found' do
      it 'should return nil' do
        expect(described_class.find('foobar', database_id: 'barfoo')).to be_nil
        expect(described_class.find('foobar', database_id: form.app_id)).to be_nil
      end
    end
  end

  describe '.new' do
    it 'should pass all params except form to super' do
      form = TaskHelper::Form.all.first
      record = described_class.new(app_id: form.app_id, form: form,
        'entity_id' => form.id)
      expect(record.app_id).to eq(form.app_id)
      expect(record.entity_id).to eq(form.id)
    end

    context 'given an optional form' do
      it 'should store the form' do
        form = TaskHelper::Form.all.first
        expect(TaskHelper::Form).not_to receive(:find)
        record = described_class.new(form: form)
        expect(record.form).to eq(form)
      end
    end

    context 'without optional form' do
      it 'should fetch the form when needed' do
        expect(TaskHelper::Form).to receive(:find).at_least(1)
        described_class.new.form
      end
    end
  end

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
