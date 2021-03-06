class Api::V1::TasksController < ApplicationController
  include Api::V1::TasksDoc
  before_action :find_task, only: [:show, :destroy, :update]

  def index
    @tasks = Task.where(project_id: params[:project_id])
    authorize @tasks
    render json: json_resources(Api::V1::TaskResource, @tasks)
  end

  def show
    authorize @task
    render json: json_resource(Api::V1::TaskResource, @task)
  end

  def create
    @task = Task.new(task_attributes)
    @task.project = Project.find(task_project[:id])
    authorize @task

    if @task.save
      render json: json_resource(Api::V1::TaskResource, @task),
        status: :created
    else
      respond_with_errors(@task)
    end
  end

  def update
    authorize @task
    if @task.update_attributes(task_attributes)
      head :ok
    else
      respond_with_errors(@task)
    end
  end

  def destroy
    authorize @task
    @task.destroy
    head :no_content
  end

  private

  def find_task
    @task = Task.find_by_id(params[:id])
    head :not_found unless @task
  end

  def task_params
    params.require(:data).permit(:type, {
      attributes: [:name, :done, :due_date, :position],
      relationships: {
        project: { data: [:id, :type] }
      }})
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
