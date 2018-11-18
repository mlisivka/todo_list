# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task_id) { nil }
  let(:headers) { valid_headers }
  let(:relationships) do
    {
      project: {
        data: { type: 'projects', id: project.id }
      }
    }
  end
  let(:params) do
    make_params(type: 'tasks',
                id: task_id,
                attributes: attributes,
                relationships: relationships).to_json
  end

  describe '#index' do
    let!(:task) { create(:task, project: project) }
    let!(:tasks) { create_list(:task, 3, project: project) }
    let!(:task_with_pos) { create(:task, project: project, position: 1) }

    before do
      get api_v1_project_tasks_path(project), headers: headers
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
      get api_v1_project_task_path(project, task), headers: headers
    end

    it_behaves_like 'respond body JSON with attributes'

    it 'returns correct data' do
      id = data['id'].to_i
      expect(id).to eq task.id
      expect(data['type']).to eq 'tasks'
    end

    context 'when project not found' do
      let(:task) { build(:task, id: 0) }

      it_behaves_like 'returns http status', :not_found
    end
  end

  describe '#create' do
    let(:attributes) { { name: 'First Task' } }

    context 'when name is unique' do
      it 'returns http created' do
        post api_v1_project_tasks_path(project),
             params: params, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a new Task' do
        expect do
          post api_v1_project_tasks_path(project),
               params: params, headers: headers
        end.to change(Task, :count).by(1)
      end
    end

    context 'when name is empty' do
      let(:attributes) { { name: '' } }

      before do
        post api_v1_project_tasks_path(project),
             params: params, headers: headers
      end

      it_behaves_like 'returns http status', :unprocessable_entity

      it 'returns error' do
        expect(errors[0]['detail']).to eq 'The field is required.'
      end
    end
  end

  describe '#update' do
    let(:attributes) { { name: 'New Name' } }
    let(:task_id) { task.id }

    before do
      patch api_v1_project_task_path(project, task_id),
            params: params, headers: headers
    end

    context 'when there is a task' do
      let(:task) { create(:task, project: project) }

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
      let(:attributes) { { done: done } }

      context 'when a task was marked as not done' do
        let(:task) { create(:task, project: project, done: false) }
        let(:done) { true }

        it_behaves_like 'returns http status', :success

        it 'mark as done' do
          task.reload
          expect(task.done).to be_truthy
        end
      end

      context 'when a task was marked as done' do
        let(:task) { create(:task, project: project, done: true) }
        let(:done) { false }

        it_behaves_like 'returns http status', :success

        it 'mark as not done' do
          task.reload
          expect(task.done).to be_falsey
        end
      end
    end

    context 'with due_date attribute' do
      let(:task) { create(:task, project: project) }
      let(:attributes) { { due_date: time } }

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
        let(:attributes) { { position: '2' } }

        it 'updates position for task' do
          patch api_v1_project_task_path(project, task),
                params: params, headers: headers
          task.reload
          expect(task.position).to eq 2
        end
      end
    end
  end

  describe '#destroy' do
    let!(:task) { create(:task, project: project) }

    it 'returns http no_content' do
      delete api_v1_project_task_path(project, task), headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a task' do
      expect do
        delete api_v1_project_task_path(project, task), headers: headers
      end.to change(Task, :count).by(-1)
    end

    context 'when project not found' do
      let(:task) { build(:task, id: 0) }

      before do
        delete api_v1_project_task_path(project, task), headers: headers
      end

      it_behaves_like 'returns http status', :not_found
    end
  end
end
