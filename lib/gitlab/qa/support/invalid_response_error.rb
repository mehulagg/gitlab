class InvalidResponseError < StandardError
  attr_reader :response

  def initialize(address, response)
    @response = response

    super "Invalid response received from #{address}"
  end
end
