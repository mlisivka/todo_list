class ImageDecoder
  attr_reader :file_data, :filename, :content_type

  def initialize(image)
    @file_data = image[:file_data]
    @filename = image[:filename]
    @content_type = image[:content_type]
  end

  def decode
    data = StringIO.new(Base64.decode64(file_data))

    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = filename
    data.content_type = content_type
    data
  end
end
