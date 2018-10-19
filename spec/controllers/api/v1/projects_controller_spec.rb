require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :controller do
  describe '#create' do
    let(:user) { create(:user) }
    let(:params) do
      {
        data: {
          type: 'projects',
          attributes: {
            name: 'First Project'
          },
          relationships: {
            user: {
              data: {type: 'user', id: user.id}
            }
          }
        }
      }
    end

    context 'when name is unique' do
      it 'returns http created' do
        post :create, params: params
        expect(response).to have_http_status(:created)
      end

      it 'creates a new Project' do
        expect { post :create, params: params }.to change(Project, :count).by(1)
      end
    end

    context 'when name is not unique' do
      before do
        create(:project, name: 'First Project', user: user)
      end

      it 'returns http unprocessable_entity' do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error' do
        post :create, params: params
        expect(errors[0]['detail']).to eq 'The project with such name does already exist.'
      end
    end

    context 'when name is empty' do
      let(:params) do
        {
          data: {
            type: 'projects',
            attributes: {
              name: ''
            },
            relationships: {
              user: {
                data: {type: 'user', id: user.id}
              }
            }
          }
        }
      end

      it 'returns http unprocessable_entity' do
        post :create, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error' do
        post :create, params: params
        expect(errors[0]['detail']).to eq 'The field is required.'
      end
    end
  end
end