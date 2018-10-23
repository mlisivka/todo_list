module RequestSpecHelper
  def errors
    json['errors']
  end

  def data
    json['data']
  end

  def json
    JSON.parse(response.body)
  end
end
