class Api::V1::TasksController < ApplicationController
  def create
    @task = Task.new(task_attributes)
    @task.project = Project.find(task_project[:id])

    if @task.save
      render json: @task, status: :created,
        location: api_v1_project_tasks_url(@task)
    else
      respond_with_errors(@task)
    end
  end

  private

  def task_params
    params.require(:data).permit(:type, {
      attributes: [:name],
      relationships: { project: { data: [:id, :type]}}})
  end

  def task_project
    task_relationships[:project][:data]
  end

  def task_attributes
    task_params[:attributes] || {}
  end

  def task_relationships
    task_params[:relationships] || {}
  end
end
