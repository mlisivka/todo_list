module Api::V1::TasksDoc
  extend Apipie::DSL::Concern

  def self.superclass
    Api::V1::TasksController
  end

  resource_description do
    resource_id 'Tasks'
    formats [:json]
    api_versions '1'
  end

  def_param_group :task do
    param :data, Hash, only_in: :request, required: true do
      param :type, String, 'tasks', required: true
      param :attributes, Hash, required: true do
        param :name, String, 'A name of a new task'
        param :due_date, DateTime, 'Date and time of the end of the task'
        param :done, String, 'Mark task as done/undone'
      end
    end

    property :data, Hash do
      property :type, String, 'tasks'
      property :attributes, Hash do
        property :name, String, 'A name of a task'
        property :due_date, DateTime, 'Date and time of the end of the task'
        property :done, String, 'Mark task as done/undone'
      end
      property :relationships, Hash do
        property :comments, Hash do
          property :links, String, "The links to get all task's comments"
        end
        property :projects, Hash do
          property :links, String, "The links to get all task's projects"
        end
      end
    end
  end

  api :GET, '/tasks', 'Get all tasks'
  header 'Authentication', 'Auth header', required: true
  returns code: 200, array_of: :task
  def index; end

  api :GET, '/tasks/:id', 'Get a task'
  header 'Authentication', 'Auth header', required: true
  returns code: 200 do
    param_group :task
  end
  def show; end

  api :POST, '/tasks', 'Create a task'
  header 'Authentication', 'Auth header', required: true
  param_group :task
  error 422, 'The name field is required.'
  error 422, "The time can't be in the past"
  returns code: 201 do
    param_group :task
  end
  def create; end

  api :PATCH, '/tasks/:id', 'Update a task'
  header 'Authentication', 'Auth header', required: true
  param_group :task
  error 404, 'The task is not found.'
  error 422, 'The name field is required.'
  returns code: 200 do
    param_group :task
  end
  def update; end

  api :DELETE, '/tasks/:id', 'Delete a task'
  header 'Authentication', 'Auth header', required: true
  returns code: 204
  def destroy; end
end
