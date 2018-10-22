RSpec.shared_examples 'returns http status' do |status|
  it status do
    expect(response).to have_http_status(status)
  end
end
