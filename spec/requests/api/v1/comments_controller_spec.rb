# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CommentsController, type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project) }
  let(:file_format) { 'image/jpg' }
  let(:file_path) { 'spec/fixtures/images/ruby.jpg' }
  let(:comment_id) { nil }
  let(:included) { nil }
  let(:headers) { valid_headers }
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
  let(:params) do
    make_params(type: 'comments',
                id: comment_id,
                attributes: attributes,
                relationships: relationships,
                included: included).to_json
  end

  describe '#index' do
    let!(:comment) do
      create(:comment, task: task, user: user,
                       image: fixture_file_upload(file_path, file_format))
    end

    before do
      get api_v1_project_task_comments_path(project, task), headers: headers
    end

    it_behaves_like 'respond body JSON with attributes'
    it_behaves_like 'returns correct data by', 'comment'

    it 'returns with task relationsps' do
      task_data = data[0]['relationships']['task']['data']
      task_id = task_data['id'].to_i

      expect(task_id).to eq task.id
      expect(task_data['type']).to eq 'tasks'
    end

    it 'returns with user relationsps' do
      user_data = data[0]['relationships']['user']['data']
      user_id = user_data['id'].to_i

      expect(user_id).to eq user.id
      expect(user_data['type']).to eq 'users'
    end

    it 'returns image' do
      image = data[0]['attributes']['image']
      expect(image['url']).to be_present
    end
  end

  describe '#show' do
    let!(:comment) do
      create(:comment, task: task, user: user,
                       image: fixture_file_upload(file_path, file_format))
    end
    let(:comment_id) { comment.id }

    before do
      get api_v1_project_task_comment_path(project, task, comment),
          headers: headers
    end

    it_behaves_like 'respond body JSON with attributes'
    it_behaves_like 'returns correct data by', 'comment'

    it 'returns correct data' do
      id = data['id'].to_i
      expect(id).to eq comment.id
      expect(data['type']).to eq 'comments'
    end

    it 'returns with task relationsps' do
      task_data = data['relationships']['task']['data']
      task_id = task_data['id'].to_i

      expect(task_id).to eq task.id
      expect(task_data['type']).to eq 'tasks'
    end

    it 'returns with user relationsps' do
      user_data = data['relationships']['user']['data']
      user_id = user_data['id'].to_i

      expect(user_id).to eq user.id
      expect(user_data['type']).to eq 'users'
    end

    it 'returns image' do
      image = data['attributes']['image']
      expect(image['url']).to be_present
    end

    context 'when comment not found' do
      let(:comment) { build(:comment, task: task, id: 0) }

      it_behaves_like 'returns http status', :not_found
    end
  end

  describe '#create' do
    let(:attributes) { { body: 'New Comment' } }

    context 'when body is present' do
      it 'returns http created' do
        post api_v1_project_task_comments_path(project, task),
             params: params, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'creates a new comment' do
        expect do
          post api_v1_project_task_comments_path(project, task),
               params: params, headers: headers
        end.to change(Comment, :count).by(1)
      end
    end

    context 'when body is empty' do
      let(:attributes) { { body: '' } }

      before do
        post api_v1_project_task_comments_path(project, task),
             params: params, headers: headers
      end

      it_behaves_like 'returns http status', :unprocessable_entity
      it_behaves_like 'returns correct data by', 'comment'

      it 'returns error' do
        expect(errors[0]['detail']).to eq 'The field is required.'
      end
    end

    context 'with attachment' do
      let(:attributes) { { body: 'Attachment' } }
      let(:image) { fixture_file_upload(file_path, file_format) }
      let(:included) do
        {
          image: {
            data: {
              type: 'images',
              content_type: image.content_type,
              filename: image.original_filename,
              file_data: Base64.encode64(image.read)
            }
          }
        }
      end

      before do
        post api_v1_project_task_comments_path(project, task),
             params: params, headers: headers
      end

      it_behaves_like 'returns http status', :created
      it_behaves_like 'returns correct data by', 'comment'

      it 'creates a new comment with image' do
        comment = Comment.last
        expect(comment.image).to be_present
      end

      context 'when file format is wrong' do
        let(:file_format) { 'application/pdf' }

        it_behaves_like 'returns http status', :unprocessable_entity
        it_behaves_like 'returns correct data by', 'comment'

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
        it_behaves_like 'returns correct data by', 'comment'

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
    let(:comment_id) { comment.id }

    it 'returns http no_content' do
      delete api_v1_project_task_comment_path(project, task, comment),
             headers: headers
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes a comment' do
      expect do
        delete api_v1_project_task_comment_path(project, task, comment),
               headers: headers
      end.to change(Comment, :count).by(-1)
    end

    context 'when comment not found' do
      let(:comment) { build(:comment, task: task, id: 0) }

      before do
        delete api_v1_project_task_comment_path(project, task, comment),
               headers: headers
      end

      it_behaves_like 'returns http status', :not_found
    end
  end
end
