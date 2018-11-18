module Api::V1::ProjectsDoc
  extend Apipie::DSL::Concern

  def self.superclass
    Api::V1::ProjectsController
  end

  resource_description do
    resource_id 'Projects'
    formats [:json]
    api_versions '1'
  end

  def_param_group :project do
    param :data, Hash, only_in: :request, required: true do
      param :type, String, 'projects', required: true
      param :attributes, Hash, required: true do
        param :name, String, 'A name of a project', required: true
      end
    end

    property :data, Hash do
      property :type, String, 'projects'
      property :attributes, Hash do
        property :name, String, 'A name of a new project'
      end
      property :relationships, Hash do
        property :tasks, Hash do
          property :links, String, "The links to get all project's task"
        end
      end
    end
  end


  api :GET, '/projects', 'Get all projects'
  header 'Authentication', 'Auth header', required: true
  returns code: 200, array_of: :project
  def index; end

  api :GET, '/projects/:id', 'Get a project'
  header 'Authentication', 'Auth header', required: true
  returns code: 200 do
    param_group :project
  end
  def show; end

  api :POST, '/projects', 'Create a project'
  header 'Authentication', 'Auth header', required: true
  param_group :project
  error 422, 'The name field is required.'
  error 422, 'The project with such name does already exist.'
  returns code: 201 do
    param_group :project
  end
  def create; end

  api :PATCH, '/projects/:id', 'Update a project'
  header 'Authentication', 'Auth header', required: true
  param_group :project
  error 404, 'The project is not found.'
  error 422, 'The name field is required.'
  returns code: 200 do
    param_group :project
  end
  def update; end

  api :DELETE, '/projects/:id', 'Delete a project'
  header 'Authentication', 'Auth header', required: true
  returns code: 204
  def destroy; end
end
