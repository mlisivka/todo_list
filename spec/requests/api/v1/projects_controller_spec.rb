# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :request do
  let(:user) { create(:user) }
  let(:project_id) { nil }
  let(:headers) { valid_headers }
  let(:relationships) do
    {
      user: {
        data: { type: 'users', id: user.id }
      }
    }
  end
  let(:params) do
    make_params(type: 'projects',
                id: project_id,
                attributes: attributes,
                relationships: relationships).to_json
  end

  describe '#index' do
    let!(:project) { create(:project, user: user) }

    before do
      get api_v1_projects_path, headers: headers
    end

    it_behaves_like 'respond body JSON with attributes'

    it 'returns correct data' do
      id = data[0]['id'].to_i
      expect(id).to eq project.id
      expect(data[0]['type']).to eq 'projects'
    end

    it 'returns only for this user' do
    end
  end

  describe '#show' do
    let!(:project) { create(:project, user: user) }

    before do
      get api_v1_project_path(project), headers: headers
    end

    it_behaves_like 'respond body JSON with attributes'

    it 'returns correct data' do
      id = data['id'].to_i
      expect(id).to eq project.id
      expect(data['type']).to eq 'projects'
    end
  end

  describe '#create' do
    let(:attributes) { { name: 'First Project' } }

    context 'when name is unique' do
      it 'returns http created' do
        post api_v1_projects_path, params: params, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a new Project' do
        expect { post api_v1_projects_path, params: params, headers: headers }
          .to change(Project, :count).by(1)
      end
    end

    context 'when name is not unique' do
      before do
        create(:project, name: 'First Project', user: user)
        post api_v1_projects_path, params: params, headers: headers
      end

      it_behaves_like 'returns http status', :unprocessable_entity

      it 'returns error' do
        expect(errors[0]['detail'])
          .to eq 'The project with such name does already exist.'
      end
    end

    context 'when name is empty' do
      let(:attributes) { { name: '' } }

      before do
        post api_v1_projects_path, params: params, headers: headers
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
      delete api_v1_project_path(project), headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a project' do
      expect { delete api_v1_project_path(project), headers: headers }
        .to change(Project, :count).by(-1)
    end
  end

  describe '#update' do
    let(:attributes) { { name: 'New Name' } }

    before do
      patch api_v1_project_path(project_id), params: params, headers: headers
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
