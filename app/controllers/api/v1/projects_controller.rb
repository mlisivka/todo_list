class Api::V1::ProjectsController < ApplicationController
  include Api::V1::ProjectsDoc
  before_action :find_project, only: [:show, :destroy, :update]

  def index
    @projects = current_user.projects
    render json: json_resources(Api::V1::ProjectResource, @projects)
  end

  def show
    render json: json_resource(Api::V1::ProjectResource, @project)
  end

  def create
    @project = Project.new(project_attributes)
    @project.user = current_user

    if @project.save
      render json: json_resource(Api::V1::ProjectResource, @project),
             status: :created
    else
      respond_with_errors(@project)
    end
  end

  def update
    if @project
      @project.update_attributes(project_attributes)
      render json: json_resource(Api::V1::ProjectResource, @project)
    else
      head :not_found
    end
  end

  def destroy
    @project.destroy
    head :no_content
  end

  private

  def find_project
    @project = current_user.projects.find_by_id(params[:id])
  end

  def project_params
    params.require(:data).permit(:type, {
      attributes: [:name],
      relationships: { user: { data: [:id, :type] }}})
  end

  def project_attributes
    project_params[:attributes] || {}
  end

  def project_relationships
    project_params[:relationships] || {}
  end
end
