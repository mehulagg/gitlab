require 'sinatra'

Throttle = Struct.new(:name, :context) do
  def matches?(info)
    info['throttle'] == name
  end
end

throttled_stuff = [
  Throttle.new('notes_create', nil)
]

post '/throttle' do
  logger.info request.inspect
  if throttled_stuff.any? { |throttle| throttle.matches?(JSON.parse(request.body.read)) }
    status 406
  else
    status 200
  end
end
