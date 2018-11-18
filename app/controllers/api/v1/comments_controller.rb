class Api::V1::CommentsController < ApplicationController
  include Api::V1::CommentsDoc
  before_action :find_comment, only: [:show, :destroy]

  def index
    @comments = Comment.all
    authorize @comments
    render json: json_resources(Api::V1::CommentResource, @comments,
                                options: { include: ['task', 'user'] })

  end

  def show
    authorize @comment
    render json: json_resource(Api::V1::CommentResource, @comment,
                               options: { include: ['task', 'user'] })
  end

  def create
    @comment = Comment.new(comment_attributes)
    @comment.user = current_user
    @comment.task = Task.find(params[:task_id])
    @comment.image = image_file
    authorize @comment

    if @comment.save
      render json: json_resource(Api::V1::CommentResource, @comment),
             status: :created
    else
      respond_with_errors(@comment)
    end
  end

  def destroy
    authorize @comment
    @comment.destroy
    head :no_content
  end

  private

  def find_comment
    @comment = Comment.find(params[:id])
    head :not_found unless @comment
  end

  def comment_attributes
    comment_params[:attributes] || {}
  end

  def image_file
    included = included_params[:included] || {}
    image = included[:image] || {}
    image_data = image[:data]
    if image_data
      data = StringIO.new(Base64.decode64(image_data[:file_data]))

      data.class.class_eval { attr_accessor :original_filename, :content_type }
      data.original_filename = image_data[:filename]
      data.content_type = image_data[:content_type]

      data
    end
  end

  def included_params
    params.permit(included: {
      image: {
        data: [:type, :filename, :content_type, :file_data]
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
