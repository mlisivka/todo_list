require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :controller do
  let(:project) { create(:project) }
  let(:relationships) do
    {
      project: {
        data: {type: 'project', id: project.id}
      }
    }
  end

  describe '#create' do
    let(:params) do
      {
        project_id: project.id,
        data: {
          type: 'tasks',
          attributes: {
            name: 'First Task'
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

      it 'creates a new Task' do
        expect { post :create, params: params }.to change(Task, :count).by(1)
      end
    end

    context 'when name is empty' do
      let(:params) do
        {
          project_id: project.id,
          data: {
            type: 'tasks',
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

  describe '#update' do
    let(:params) do
      {
        project_id: project.id,
        id: task_id,
        data: {
          type: 'tasks',
          id: task_id,
          attributes: {
            name: 'New Name'
          },
          relationships: relationships
        }
      }
    end

    context 'when there is a task' do
      let(:task) { create(:task, project: project) }
      let(:task_id) { task.id }

      it 'returns http success' do
        put :update, params: params
        expect(response).to have_http_status(:ok)
      end

      it 'changes a task name' do
        put :update, params: params
        task.reload
        expect(task.name).to eq 'New Name'
      end
    end

    context 'when task not found' do
      let(:task_id) { 999 }

      it 'returns http not_found' do
        put :update, params: params
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#destroy' do
    it 'returns http no_content' do
      task = create(:task, project: project)

      delete :destroy, params: { id: task.id, project_id: project.id }
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a task' do
      task = create(:task, project: project)

      expect{ delete :destroy, params: { id: task.id, project_id: project.id } }
        .to change(Task, :count).by(-1)
    end
  end
end