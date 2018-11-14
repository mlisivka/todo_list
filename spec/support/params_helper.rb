module ParamsHelper
  def make_params(options = {})
    params = {
      data: {
        type: options[:type],
        attributes: options[:attributes]
      }
    }
    params[:data][:id] = options[:id] if options[:id]
    params[:included] = options[:included] if options[:included]
    if options[:relationships]
      params[:data][:relationships] = options[:relationships]
    end

    params
  end
end
