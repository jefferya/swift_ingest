require 'spec_helper'

RSpec.describe SwiftIngest::Ingestor do
  describe '#swift_ingest' do
    it 'deposits new file' do
      sample_file = 'spec/fixtures/example.txt'

      VCR.use_cassette('swift_new_deposit') do
        swift_depositer = SwiftIngest::Ingestor.new(username: 'test:tester',
                                                    password: 'testing',
                                                    tenant: 'tester',
                                                    auth_url: 'http://www.example.com:8080/auth/v1.0',
                                                    project: 'ERA')

        deposited_file = swift_depositer.deposit_file(sample_file, 'ERA')

        expect(deposited_file).not_to be_nil
        expect(deposited_file).to be_an_instance_of(OpenStack::Swift::StorageObject)
        expect(deposited_file.name).to eql 'example'
        expect(deposited_file.container.name).to eql 'ERA'
        expect(deposited_file.metadata['project']).to eql 'ERA'
        expect(deposited_file.metadata['project-id']).to eql 'example'
        expect(deposited_file.metadata['aip-version']).to eql '1.0'
        expect(deposited_file.metadata['promise']).to eql 'bronze'
      end
    end

    it 'updates existing file' do
      sample_file = 'spec/fixtures/example.txt'

      VCR.use_cassette('swift_update_deposit') do
        swift_depositer = SwiftIngest::Ingestor.new(username: 'test:tester',
                                                    password: 'testing',
                                                    tenant: 'tester',
                                                    auth_url: 'http://www.example.com:8080/auth/v1.0',
                                                    project: 'ERA')

        # Deposits file twice, check that it only gets added once to the container
        expect do
          first_deposit = swift_depositer.deposit_file(sample_file, 'ERA')
          second_deposit = swift_depositer.deposit_file(sample_file, 'ERA')

          expect(first_deposit.name).to eq(second_deposit.name)
          expect(first_deposit.container.name).to eq(second_deposit.container.name)
        end.to change { swift_depositer.swift_connection.container('ERA').count.to_i }.by(1)
      end
    end
  end
end
