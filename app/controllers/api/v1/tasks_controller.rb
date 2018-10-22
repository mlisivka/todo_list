class Api::V1::TasksController < ApplicationController
  before_action :find_task, only: [:destroy, :update]

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

  def update
    if @task
      @task.update_attributes(task_attributes)
      render json: @task, status: :ok
    else
      render json: {}, status: :not_found
    end
  end

  def destroy
    @task.destroy
    head :no_content
  end

  private

  def find_task
    @task = Task.find_by_id(params[:id])
  end

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
