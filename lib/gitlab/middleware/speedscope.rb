# frozen_string_literal: true

require 'stackprof'

module Gitlab
  module Middleware
    class Speedscope
      def initialize(app)
        @app = app
      end

      def call(env)
        status = headers = body = nil
        query_string = env['QUERY_STRING']
        path         = env['PATH_INFO'].sub('//', '/')

        flamegraph = nil

        if query_string =~ /pp=flamegraph/
          flamegraph = ::StackProf.run(
            mode: :wall,
            raw: true,
            aggregate: false,
            interval: (0.5 * 1000).to_i
          ) do
            status, headers, body = @app.call(env)
          end
        end

        if flamegraph
          body.close if body.respond_to? :close
          return flamegraph(flamegraph, path)
        end

        status, headers, body = @app.call(env)
      end

      def flamegraph(graph, path)
        headers = { 'Content-Type' => 'text/html' }
        [200, headers, [graph]]
        if Hash === graph
          html = <<~HTML
            <!DOCTYPE html>
            <html>
              <head>
                <style>
                  body { margin: 0; height: 100vh; }
                  #speedscope-iframe { width: 100%; height: 100%; border: none; }
                </style>
              </head>
              <body>
                <script type="text/javascript">
                  var graph = #{JSON.generate(graph)};
                  var json = JSON.stringify(graph);
                  var blob = new Blob([json], { type: 'text/plain' });
                  var objUrl = encodeURIComponent(URL.createObjectURL(blob));
                  var iframe = document.createElement('IFRAME');
                  iframe.setAttribute('id', 'speedscope-iframe');
                  document.body.appendChild(iframe);
                  var iframeUrl = '/speedscope/index.html#profileURL=' + objUrl + '&title=' + 'Flamegraph for #{CGI.escape(path)}';
                  iframe.setAttribute('src', iframeUrl);
                </script>
              </body>
            </html>
          HTML
          [200, headers, [html]]
        else
          [200, headers, [graph]]
        end
      end
    end
  end
end
