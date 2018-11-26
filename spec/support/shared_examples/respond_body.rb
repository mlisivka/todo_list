RSpec.shared_examples 'respond body JSON with attributes' do
  it { expect(json).to be_kind_of(Hash) }
end

RSpec.shared_examples 'returns correct data by' do |schema|
  it { expect(response).to match_json_schema(schema) }
end
