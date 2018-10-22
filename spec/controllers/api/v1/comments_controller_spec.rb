require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:task) { create(:task) }
  let(:relationships) do
    {
      user: {
        data: {type: 'users', id: user.id}
      },
      task: {
        data: {type: 'tasks', id: task.id}
      }
    }
  end

  def params_with_body(body)
    {
      project_id: task.project.id,
      task_id: task.id,
      data: {
        type: 'comment',
        attributes: {
          body: body
        },
        relationships: relationships
      }
    }
  end

  describe '#create' do
    let(:params) { params_with_body('New Comment') }

    context 'when body is present' do
      it 'returns http created' do
        post :create, params: params
        expect(response).to have_http_status(:created)
      end

      it 'creates a new Task' do
        expect { post :create, params: params }.to change(Comment, :count).by(1)
      end
    end

    context 'when body is empty' do
      let(:params) { params_with_body('') }

      before do
        post :create, params: params
      end

      it_behaves_like 'returns http status', :unprocessable_entity

      it 'returns error' do
        expect(errors[0]['detail']).to eq 'The field is required.'
      end
    end
  end
end
