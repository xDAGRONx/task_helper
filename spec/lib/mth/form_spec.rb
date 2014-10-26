describe MTH::Form do
  before(:all) { MTH::API.rest_api_key = 'foobar' }
  after(:all) { MTH::API.rest_api_key = nil }

  describe '.all' do
    it 'should return all forms for all databases' do
      forms = FixtureParser.pretty(:forms)
      expect(described_class.all.all? { |f| f.kind_of?(described_class) })
        .to be(true)
      expect(described_class.all).to match_array(forms)
    end
  end

  describe '.find' do
    it 'should return the corresponding form if found' do
      form = FixtureParser.pretty(:forms).sample
      result = described_class.find(database: form.app_id, form: form.id)
      expect(result).to be_a(described_class)
      expect(result).to eq(form)
    end

    it 'should retrun nil if the form is not found' do
      expect(described_class.find(database: 'hasdof', form: 'hasdof'))
        .to be_nil
    end
  end

  describe '.find_by' do
    it 'should return the corresponding form if found' do
      form = FixtureParser.pretty(:forms).sample
      db = FixtureParser.pretty(:database, form.app_id)
      result = described_class.find_by(database_name: db.name,
                                       form_name: form.name)
      expect(result).to be_a(described_class)
      expect(result).to eq(form)
    end

    it 'should retrun nil if the form is not found' do
      expect(described_class.find_by(database_name: 'hasdof',
        form_name: 'hasdof')).to be_nil
    end
  end

  describe '#database' do
    it 'should return the database associated with the form' do
      form = described_class.new(FixtureParser.forms.sample)
      expect(form.database).to be_a(MTH::Database)
      expect(form.database.id).to eq(form.app_id)
    end
  end

  describe '#fields' do
    it 'should return the associated fields' do
      form = described_class.new(FixtureParser.forms.sample)
      expect(form.fields.all? { |f| f.kind_of?(MTH::Field) }).to be(true)
      expect(form.fields.all? { |f| f.entity_id == form.id }).to be(true)
    end
  end

  describe '#records' do
    context 'form has no fields' do
      it 'should return nil' do
        if form = described_class.all.find { |f| f.fields.none? }
          expect(form.records).to be(nil)
        else
          expect(MTH::Field).to receive(:get).and_return('fields' => [])
          expect(described_class.new.records).to be(nil)
        end
      end
    end

    context 'form has at least one field' do
      it 'should return a lazy enumerator containing the associated records' do
        if form = described_class.all.find { |f| f.fields.any? }
          expect(form.records).to be_a(Enumerator::Lazy)
          expect(form.records.first).to be_a(MTH::Record)
          expect(form.records.first.entity_id).to eq(form.id)
        else
          raise 'No forms with fields found'.inspect
        end
      end
    end
  end

  describe 'data members' do
    described_class.data_members.each do |m|
      describe "##{m}" do
        it "should return the value of #{m}" do
          form = described_class.new(FixtureParser.forms.sample)
          data = FixtureParser.pretty(:form, form.id, form.database.id)
          expect(form.public_send(m)).to eq(data.send(m))
        end
      end
    end
  end
end
