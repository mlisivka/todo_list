module ErrorSerializer
  def self.serialize(object, status = 422)
    if object.is_a?(StandardError)
      [{
        status: status,
        detail: object.message
      }]
    else
      object.errors.messages.map do |field, errors|
        errors.map do |error_message|
          {
            status: status,
            source: {pointer: "/data/attributes/#{field}"},
            detail: error_message
          }
        end
      end.flatten
    end
  end
end
