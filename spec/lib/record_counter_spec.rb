require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecordCounter do

  describe :new do

    it 'creates an attr_reader for each table' do
      counter = RecordCounter.new(InfoRequest)
      expect(counter).to respond_to :info_requests
    end

  end

  describe :tables do

    it 'returns the tables that will be counted' do
      counter = RecordCounter.new(InfoRequest, User, :spam_addresses)
      expected = ['info_requests', 'users', 'spam_addresses']
      expect(counter.tables).to eq(expected)
    end

  end

  describe :run do

    it 'counts the records in a single table' do
      Holiday.destroy_all
      10.times { FactoryGirl.create(:holiday) }
      counter = RecordCounter.new(Holiday)
      counter.run
      expect(counter.holidays).to eq(10)
    end

    it 'counts the records in multiple tables' do
      Holiday.destroy_all
      SpamAddress.destroy_all
      10.times { FactoryGirl.create(:holiday) }
      10.times { FactoryGirl.create(:spam_address) }

      counter = RecordCounter.new(Holiday, SpamAddress)
      counter.run
      actual = { :holidays => counter.holidays,
                 :spam_addresses => counter.spam_addresses }

      expect(actual).to eq({ :holidays => 10, :spam_addresses => 10 })
    end

    it 'returns the counter instance' do
      Holiday.destroy_all
      10.times { FactoryGirl.create(:holiday) }
      counter = RecordCounter.new(Holiday)
      expect(counter.run).to eq(counter)
    end
  end

end
