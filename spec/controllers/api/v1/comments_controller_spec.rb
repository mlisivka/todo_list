require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:task) { create(:task) }
  let(:project) { task.project }
  let(:relationships) do
    {
      user: {
        data: { type: 'users', id: user.id }
      },
      task: {
        data: { type: 'tasks', id: task.id }
      }
    }
  end

  def params_with_body(body)
    {
      project_id: project.id,
      task_id: task.id,
      data: {
        type: 'comments',
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

      it 'creates a new comment' do
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

    context 'with attachment' do
      let(:file_format) { 'image/jpg' }
      let(:file_path) { 'spec/fixtures/images/ruby.jpg' }
      let(:params) do
        params_with_body('With image').merge(
          included: {
            image: {
              data: {
                type: 'images',
                image: fixture_file_upload(file_path, file_format)
              }
            }
          }
        )
      end

      before do
        post :create, params: params
      end

      it_behaves_like 'returns http status', :success

      it 'creates a new comment with image' do
        comment = Comment.last
        expect(comment.image).to be_present
      end

      context 'when file format is wrong' do
        let(:file_format) { 'application/pdf' }

        it_behaves_like 'returns http status', :unprocessable_entity

        it 'returns error' do
          expect(errors[0]['detail'])
            .to eq 'Wrong file format. ' \
              'You can upload a *.jpg or *.png formats files only'
        end
      end

      context 'when file is too large' do
        let(:file_format) { 'image/jpg' }
        let(:file_path) { 'spec/fixtures/images/high.jpg' }

        it_behaves_like 'returns http status', :unprocessable_entity

        it 'returns error' do
          expect(errors[0]['detail'])
            .to eq 'An uploaded file is too large. ' \
              'The size shouldn’t exceed 10 MB MB.'
        end
      end
    end
  end

  describe '#destroy' do
    let!(:comment) { create(:comment, task: task, user: user) }
    let(:params) do
      {
        id: comment.id,
        task_id: task.id,
        project_id: project.id
      }
    end

    it 'returns http no_content' do
      delete :destroy, params: params
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a comment' do
      expect { delete :destroy, params: params }
        .to change(Comment, :count).by(-1)
    end
  end
end
