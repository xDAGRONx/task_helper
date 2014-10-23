describe MTH::Database do
  before(:all) { MTH::API.rest_api_key = 'foobar' }
  after(:all) { MTH::API.rest_api_key = nil }

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

  it 'should define getters for data members' do
    db = described_class.all.sample
    db_hash = FixtureParser.database(db.id)
    %w(name dtypes_count entities_count properties_count).each do |member|
      expect(db.public_send(member)).to eq(db_hash[member])
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
end
