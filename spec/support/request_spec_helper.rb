module RequestSpecHelper
  # Parse JSON response to ruby hash
  def response_json
    JSON.parse(response.body)
  end
end
