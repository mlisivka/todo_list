class Api::V1::ProjectsController < ApplicationController
  before_action :find_project, only: [:destroy, :update]

  def_param_group :project do
    param :data, Hash do
      param :type, String, 'projects'
      param :attributes, Hash do
        param :name, String, 'The name of a new project'
      end
    end
  end

  api :POST, '/projects', 'Create a project'
  param_group :project
  error 422, 'The field is required.'
  error 422, 'The project with such name does already exist.'
  def create
    @project = Project.new(project_attributes)
    @project.user = User.find(project_user[:id])

    if @project.save
      render json: @project, status: :created,
        location: api_v1_projects_url(@project)
    else
      respond_with_errors(@project)
    end
  end

  api :PUT, '/projects/:id', 'Update a project'
  error 404, 'The project is not found.'
  def update
    if @project
      @project.update_attributes(project_attributes)
      render json: @project, status: :ok
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
