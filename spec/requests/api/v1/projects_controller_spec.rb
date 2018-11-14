# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :request do
  let(:user) { create(:user) }
  let(:relationships) do
    {
      user: {
        data: { type: 'users', id: user.id }
      }
    }
  end

  describe '#index' do
    let!(:project) { create(:project, user: user) }

    before do
      get api_v1_projects_path
    end

    it_behaves_like 'respond body JSON with attributes'

    it 'returns correct data' do
      id = data[0]['id'].to_i
      expect(id).to eq project.id
      expect(data[0]['type']).to eq 'projects'
    end
  end

  describe '#show' do
    let!(:project) { create(:project, user: user) }

    before do
      get api_v1_project_path(project)
    end

    it_behaves_like 'respond body JSON with attributes'

    it 'returns correct data' do
      id = data['id'].to_i
      expect(id).to eq project.id
      expect(data['type']).to eq 'projects'
    end
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
        post api_v1_projects_path, params: params
        expect(response).to have_http_status(:created)
      end

      it 'creates a new Project' do
        expect { post api_v1_projects_path, params: params }
          .to change(Project, :count).by(1)
      end
    end

    context 'when name is not unique' do
      before do
        create(:project, name: 'First Project', user: user)
        post api_v1_projects_path, params: params
      end

      it_behaves_like 'returns http status', :unprocessable_entity

      it 'returns error' do
        expect(errors[0]['detail'])
          .to eq 'The project with such name does already exist.'
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

      before do
        post api_v1_projects_path, params: params
      end

      it_behaves_like 'returns http status', :unprocessable_entity

      it 'returns error' do
        expect(errors[0]['detail']).to eq 'The field is required.'
      end
    end
  end

  describe '#destroy' do
    let!(:project) { create(:project, user: user) }

    it 'returns http no_content' do
      delete api_v1_project_path(project)
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a project' do
      expect { delete api_v1_project_path(project) }
        .to change(Project, :count).by(-1)
    end
  end

  describe '#update' do
    let(:params) do
      {
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

    before do
      patch api_v1_project_path(project_id), params: params
    end

    context 'when there is a project' do
      let(:project) { create(:project, user: user) }
      let(:project_id) { project.id }

      it_behaves_like 'returns http status', :success

      it 'changes a project name' do
        project.reload
        expect(project.name).to eq 'New Name'
      end
    end

    context 'when project not found' do
      let(:project_id) { 999 }

      it_behaves_like 'returns http status', :not_found
    end
  end
end
