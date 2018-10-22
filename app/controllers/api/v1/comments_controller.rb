class Api::V1::CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_attributes)
    @comment.user = User.find(comment_user[:id])
    @comment.task = Task.find(comment_task[:id])

    if @comment.save
      render json: @comment, status: :created,
        location: api_v1_project_task_comments_url(@comment)
    else
      respond_with_errors(@comment)
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    head :no_content
  end

  private

  def comment_attributes
    comment_params[:attributes] || {}
  end

  def comment_user
    comment_relationships[:user][:data]
  end

  def comment_task
    comment_relationships[:task][:data]
  end

  def comment_relationships
    comment_params[:relationships] || {}
  end

  def comment_params
    params.require(:data).permit(:type, {
      attributes: [:body],
      relationships: {
        task: { data: [:id, :type] },
        user: { data: [:id, :type] }
      }})
  end
end
