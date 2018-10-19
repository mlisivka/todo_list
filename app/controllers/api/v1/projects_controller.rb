class Api::V1::ProjectsController < ApplicationController
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

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      render json: {}, status: :no_content
    end
  end

  private

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
