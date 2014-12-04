describe TaskHelper::Database do
  before(:all) { TaskHelper::API.rest_api_key = 'foobar' }
  after(:all) { TaskHelper::API.rest_api_key = nil }

  describe '.all' do
    it 'should return an array of databases' do
      expect(described_class.all.first).to be_a(described_class)
    end

    it 'should return databases corresponding to the API response' do
      expect(described_class.all.map(&:to_h).to_json)
        .to eq(FixtureParser.databases.to_json)
    end
  end

  describe '.find_by' do
    it 'should return the corresponding database if found' do
      db = described_class.all.sample
      expect(described_class.find_by(name: db.name)).to eq(db)
    end

    it 'should return nil if no database found' do
      expect(described_class.find_by(name: 'odiasoutee')).to be_nil
    end
  end

  describe '.find_by_name' do
    it 'should return the corresponding database if found' do
      db = described_class.all.sample
      expect(described_class.find_by_name(db.name)).to eq(db)
    end

    it 'should return nil if no database found' do
      expect(described_class.find_by_name('odiasoutee')).to be_nil
    end
  end

  describe '.find' do
    it 'should return the corresponding database if found' do
      db = described_class.all.sample
      expect(described_class.find(db.id)).to eq(db)
    end

    it 'should retrun nil if the database is not found' do
      expect(described_class.find('hasdof')).to be_nil
    end
  end

  describe 'data members' do
    described_class.data_members.each do |m|
      describe "##{m}" do
        it "should return the value of #{m}" do
          db = described_class.new(FixtureParser.databases.sample)
          data = FixtureParser.pretty(:database, db.id)
          expect(db.public_send(m)).to eq(data.send(m))
        end
      end
    end
  end

  describe '#created_at' do
    it 'should return the parsed time of created_at' do
      db = described_class.all.sample
      db_hash = FixtureParser.database(db.id)
      expect(db.created_at).to eq(Time.parse(db_hash['created_at']))
    end
  end

  describe '#updated_at' do
    it 'should return the parsed time of updated_at' do
      db = described_class.all.sample
      db_hash = FixtureParser.database(db.id)
      expect(db.updated_at).to eq(Time.parse(db_hash['updated_at']))
    end
  end

  describe '#forms' do
    it 'should return all forms associated with the database' do
      db = described_class.all.sample
      forms = FixtureParser.pretty(:forms, db.id)
      expect(db.forms.all? { |f| f.kind_of?(TaskHelper::Form) }).to be(true)
      expect(db.forms).to match_array(forms)
    end
  end
end
