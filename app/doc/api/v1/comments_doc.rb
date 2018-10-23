module Api::V1::CommentsDoc
  extend Apipie::DSL::Concern

  def self.superclass
    Api::V1::CommentsController
  end

  resource_description do
    resource_id 'Comments'
    formats [:json]
    api_versions '1'
  end

  def_param_group :comment do
    param :data, Hash, only_in: :request, required: true do
      param :type, String, 'comments', required: true
      param :attributes, Hash, required: true do
        param :body, String, 'A body of a comment', required: true
      end
      param :included, Hash do
        param :image, Hash do
          param :data, Hash do
            param :type, String, 'images', required: true
            param :url, String, 'Path to file'
          end
        end
      end
    end

    property :data, Hash do
      property :type, String, 'comments'
      property :attributes, Hash do
        property :name, String, 'A name of a new comment'
        property :image, Hash do
          property :url, String, 'Path to file'
        end
        property :created_at, DateTime
      end
      property :relationships, Hash do
        property :users, Hash do
          property :links, String, "The links to get all comment's user"
          property :data, Hash do
            property :type, String, 'users'
            property :id, Integer
          end
        end
        property :tasks, Hash do
          property :links, String, "The links to get all comment's task"
          property :data, Hash do
            property :type, String, 'tasks'
            property :id, Integer
          end
        end
      end
    end
  end


  api :GET, '/comments', 'Get all comments'
  returns code: 200, array_of: :comment
  def index; end

  api :GET, '/comments/:id', 'Get a comment'
  returns code: 200 do
    param_group :comment
  end
  def show; end

  api :POST, '/comments', 'Create a comment'
  param_group :comment
  error 422, 'The body field is required.'
  error 422, 'File too large. Max 10 MB'
  error 422, 'Wrong file format. Allowed: *.jpg, *.png'
  returns code: 201 do
    param_group :comment
  end
  def create; end

  api :PATCH, '/comments/:id', 'Update a comment'
  param_group :comment
  error 404, 'The comment is not found.'
  error 422, 'The body field is required.'
  error 422, 'File too large. Max 10 MB'
  error 422, 'Wrong file format. Allowed: *.jpg, *.png'
  returns code: 200 do
    param_group :comment
  end
  def update; end

  api :DELETE, '/comments/:id', 'Delete a comment'
  returns code: 204
  def destroy; end
end
