class Api::V1::ProjectsController < ApplicationController
  before_action :find_project, only: [:show, :destroy, :update]

  def_param_group :project do
    param :data, Hash do
      param :type, String, 'projects'
      param :attributes, Hash do
        param :name, String, 'The name of a new project'
      end
    end
  end

  def index
    @projects = Project.all
    render json: json_resources(Api::V1::ProjectResource, @projects)
  end

  def show
    render json: json_resource(Api::V1::ProjectResource, @project)
  end

  api :POST, '/projects', 'Create a project'
  param_group :project
  error 422, 'The field is required.'
  error 422, 'The project with such name does already exist.'
  def create
    @project = Project.new(project_attributes)
    @project.user = User.find(project_user[:id])

    if @project.save
      render json: json_resource(Api::V1::ProjectResource, @project),
        status: :created
    else
      respond_with_errors(@project)
    end
  end

  api :PUT, '/projects/:id', 'Update a project'
  error 404, 'The project is not found.'
  def update
    if @project
      @project.update_attributes(project_attributes)
      render json: json_resource(Api::V1::ProjectResource, @project)
    else
      render json: {}, status: :not_found
    end
  end

  api :DELETE, '/projects/:id', 'Delete a project'
  def destroy
    @project.destroy
    head :no_content
  end

  private

  def find_project
    @project = Project.find_by_id(params[:id])
  end

  def project_params
    params.require(:data).permit(:type, {
      attributes: [:name],
      relationships: { user: { data: [:id, :type]}}})
  end

  def project_attributes
    project_params[:attributes] || {}
  end

  def project_relationships
    project_params[:relationships] || {}
  end

  def project_user
    project_relationships[:user][:data]
  end
end
