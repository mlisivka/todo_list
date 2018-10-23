RSpec.shared_examples 'respond body JSON with attributes' do
  it { expect(json).to be_kind_of(Hash) }
end
