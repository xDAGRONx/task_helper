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
