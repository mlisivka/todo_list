module RequestSpecHelper
  def errors
    json['errors']
  end

  def json
    JSON.parse(response.body)
  end
end
