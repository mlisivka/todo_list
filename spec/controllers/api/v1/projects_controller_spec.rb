require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :controller do
  let(:user) { create(:user) }
  let(:relationships) do
    {
      user: {
        data: {type: 'user', id: user.id}
      }
    }
  end

  describe '#create' do
    let(:params) do
      {
        data: {
          type: 'projects',
          attributes: {
            name: 'First Project'
          },
          relationships: relationships
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
            relationships: relationships
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

  describe '#destroy' do
    it 'returns http no_content' do
      project = create(:project, user: user)

      delete :destroy, params: { id: project.id }
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a project' do
      project = create(:project, user: user)

      expect{ delete :destroy, params: { id: project.id } }
        .to change(Project, :count).by(-1)
    end
  end

  describe '#update' do
    let(:params) do
      {
        id: project_id,
        data: {
          type: 'projects',
          id: project_id,
          attributes: {
            name: 'New Name'
          },
          relationships: relationships
        }
      }
    end

    context 'when there is a project' do
      let(:project) { create(:project, user: user) }
      let(:project_id) { project.id }

      it 'returns http success' do
        put :update, params: params
        expect(response).to have_http_status(:ok)
      end

      it 'changes a project name' do
        put :update, params: params
        project.reload
        expect(project.name).to eq 'New Name'
      end
    end

    context 'when project not found' do
      let(:project_id) { 999 }

      it 'returns http not_found' do
        put :update, params: params
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
