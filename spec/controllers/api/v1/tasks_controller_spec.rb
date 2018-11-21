require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :controller do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:headers) { valid_headers }
  let(:relationships) do
    {
      project: {
        data: { type: 'projects', id: project.id }
      }
    }
  end

  before do
    request.headers.merge! headers
  end

  describe '#index' do
    let!(:task) { create(:task, project: project) }
    let!(:tasks) { create_list(:task, 3, project: project) }
    let!(:task_with_pos) { create(:task, project: project, position: 1) }

    before do
      get :index, params: { project_id: project.id }
    end

    it_behaves_like 'respond body JSON with attributes'

    it 'returns correct data' do
      id = data[0]['id'].to_i
      expect(id).to eq task.id
      expect(data[0]['type']).to eq 'tasks'
    end

    context 'when for tasks was setted priorities' do
      it 'returns response with prioritates' do
        last_data_task = data.last
        id = last_data_task['id'].to_i
        position = last_data_task['attributes']['position']

        expect(id).to eq task_with_pos.id
        expect(position).to eq task_with_pos.position
      end

      it 'chages position of others tasks' do
        position = data[0]['attributes']['position']
        expect(position).to eq task_with_pos.position + 1
      end
    end
  end

  describe '#show' do
    let!(:task) { create(:task, project: project) }

    before do
      get :show, params: { id: task.id, project_id: project.id }
    end

    it_behaves_like 'respond body JSON with attributes'

    it 'returns correct data' do
      id = data['id'].to_i
      expect(id).to eq task.id
      expect(data['type']).to eq 'tasks'
    end
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

      before do
        post :create, params: params
      end

      it_behaves_like 'returns http status', :unprocessable_entity

      it 'returns error' do
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

    before do
      patch :update, params: params
    end

    context 'when there is a task' do
      let(:task) { create(:task, project: project) }
      let(:task_id) { task.id }

      it_behaves_like 'returns http status', :success

      it 'changes a task name' do
        task.reload
        expect(task.name).to eq 'New Name'
      end
    end

    context 'when task not found' do
      let(:task_id) { 999 }

      it_behaves_like 'returns http status', :not_found
    end

    context 'with done attribute' do
      let(:params) do
        {
          id: task.id,
          project_id: project.id,
          data: {
            type: 'tasks',
            attributes: {
              done: done
            },
            relationships: relationships
          }
        }
      end

      context 'when a task was marked as not done' do
        let(:task) { create(:task, project: project, done: false) }
        let(:done) { true }

        it_behaves_like 'returns http status', :success

        it 'marks as done' do
          task.reload
          expect(task.done).to be_truthy
        end
      end

      context 'when a task was marked as done' do
        let(:task) { create(:task, project: project, done: true) }
        let(:done) { false }

        it_behaves_like 'returns http status', :success

        it 'marks as not done' do
          task.reload
          expect(task.done).to be_falsey
        end
      end
    end

    context 'with due_date attribute' do
      let(:task) { create(:task, project: project) }
      let(:params) do
        {
          id: task.id,
          project_id: project.id,
          data: {
            type: 'tasks',
            attributes: {
              due_date: time
            },
            relationships: relationships
          }
        }
      end

      context 'when date is in the future' do
        let(:time) { (Time.now + 1.day).change(sec: 0) }

        it_behaves_like 'returns http status', :success

        it 'updates due_date' do
          task.reload
          expect(task.due_date).to eq time
        end
      end

      context 'when date is in the past' do
        let(:time) { (Time.now - 1.day).change(sec: 0) }

        it_behaves_like 'returns http status', :unprocessable_entity

        it 'returns error' do
          task.reload
          expect(errors[0]['detail']).to eq "The time can't be in the past"
        end
      end

      context 'with position attribute' do
        let!(:tasks) { create_list(:task, 3, project: project) }
        let!(:task) { create(:task, project: project) }
        let(:params) do
          {
            id: task.id,
            project_id: project.id,
            data: {
              type: 'tasks',
              attributes: {
                position: '2'
              },
              relationships: relationships
            }
          }
        end

        it 'updates position for task' do
          patch :update, params: params
          task.reload
          expect(task.position).to eq 2
        end
      end
    end
  end

  describe '#destroy' do
    let!(:task) { create(:task, project: project) }

    it 'returns http no_content' do
      delete :destroy, params: { id: task.id, project_id: project.id }
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a task' do
      expect do
        delete :destroy, params: { id: task.id, project_id: project.id }
      end.to change(Task, :count).by(-1)
    end
  end
end
