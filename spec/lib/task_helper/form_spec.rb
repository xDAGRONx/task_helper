describe TaskHelper::Form do
  before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
  after(:all) { TaskHelper::API.rest_api_key = nil }

  describe '.new' do
    context 'given an optional database' do
      it 'should store the database' do
        db = TaskHelper::Database.all.sample
        expect(TaskHelper::Database).not_to receive(:find)
        form = described_class.new(database: db)
        expect(form.database).to eq(db)
      end
    end

    context 'without optional database' do
      it 'should fetch the database when needed' do
        expect(TaskHelper::Database).to receive(:find)
        described_class.new.database
      end
    end
  end

  describe '.all' do
    it 'should return all forms for all databases' do
      forms = FixtureParser.pretty(:forms)
      expect(described_class.all.all? { |f| f.kind_of?(described_class) })
        .to be(true)
      expect(described_class.all).to match_array(forms)
    end

    it 'should use a Lazy Enumerator' do
      expect(described_class.all).to be_an(Enumerator::Lazy)
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
      expect(form.database).to be_a(TaskHelper::Database)
      expect(form.database.id).to eq(form.app_id)
    end
  end

  describe '#fields' do
    it 'should return the associated fields' do
      form = described_class.new(FixtureParser.forms.sample)
      expect(form.fields.all? { |f| f.kind_of?(TaskHelper::Field) }).to be(true)
      expect(form.fields.all? { |f| f.entity_id == form.id }).to be(true)
    end

    it "should pre-load the fields' form attribute" do
      form = described_class.all.first
      expect(described_class).not_to receive(:find)
      form.fields.first.form
    end
  end

  describe '#records' do
    context 'form has no fields' do
      it 'should return nil' do
        if form = described_class.all.find { |f| f.fields.none? }
          expect(form.records).to be(nil)
        else
          expect(TaskHelper::Field).to receive(:get).and_return('fields' => [])
          expect(described_class.new.records).to be(nil)
        end
      end
    end

    context 'form has at least one field' do
      it 'should return a lazy enumerator containing the associated records' do
        if form = described_class.all.find { |f| f.fields.any? }
          expect(form.records).to be_a(Enumerator::Lazy)
          expect(form.records.first).to be_a(TaskHelper::Record)
          expect(form.records.first.entity_id).to eq(form.id)
        else
          raise 'No forms with fields found'.inspect
        end
      end

      it "should pre-load the records' form attribute" do
        if form = described_class.all.find { |f| f.fields.any? }
          expect(described_class).not_to receive(:find)
          form.records.first.form
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
