class Api::V1::CommentsController < ApplicationController
  before_action :find_comment, only: [:show, :destroy]
  def index
    @comments = Comment.all
    render json: json_resources(Api::V1::CommentResource, @comments, options: { include: ['task', 'user'] })

  end

  def show
    render json: json_resource(Api::V1::CommentResource, @comment, options: { include: ['task', 'user'] })
  end

  def create
    @comment = Comment.new(comment_attributes)
    @comment.user = User.find(comment_user[:id])
    @comment.task = Task.find(comment_task[:id])
    @comment.image = comment_image[:image]

    if @comment.save
      render json: json_resource(Api::V1::CommentResource, @comment),
        status: :created
    else
      respond_with_errors(@comment)
    end
  end

  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def comment_attributes
    comment_params[:attributes] || {}
  end

  def comment_user
    comment_relationships[:user][:data] || {}
  end

  def comment_task
    comment_relationships[:task][:data] || {}
  end

  def comment_relationships
    comment_params[:relationships] || {}
  end

  def comment_image
    included = included_params[:included] || {}
    image = included[:image] || {}
    image[:data] || {}
  end

  def included_params
    params.permit(included: {
      image: {
      data: [:type, :image]
    }})
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
