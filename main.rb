require 'rack'
require 'thin'
require 'erb'

##
# Backport +<%=h … %>+ and also
# replace Arrays by joining content with the HTTP line break
def h(param_value)
  if param_value.is_a?(Array)
    param_value.map! {|val| Rack::Utils.escape_html(val) }.join("\r\n")
  else
    Rack::Utils.escape_html(param_value)
  end
end

RHTML = ERB.new(File.read('index.rhtml'))

begin
  server = Thin::Server.new(443, lambda do |env|
    req = Rack::Request.new(env)
    
    res = Rack::Response.new(RHTML.result_with_hash(
      title: "#{req.request_method} #{req.path}",
       get_params: req.GET,
      post_params: req.POST
    ))
    res.content_type = 'text/html'
    res.finish
  end)
  server.start
ensure
  server.stop
end