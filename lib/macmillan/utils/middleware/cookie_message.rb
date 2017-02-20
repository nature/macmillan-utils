require 'rack/request'
require 'rack/response'
require 'uri'

module Macmillan
  module Utils
    module Middleware
      class CookieMessage
        YEAR = 31_536_000
        COOKIE = 'euCookieNotice'.freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          @request = Rack::Request.new(env)

          if cookies_accepted?(@request)
            redirect_back(@request)
          else
            @app.call(env)
          end
        end

        private

        def cookies_accepted?(request)

          debug_log("request.post? IS #{request.post?.inspect}")
          debug_log("request.cookies[#{COOKIE}] IS #{request.cookies[COOKIE].inspect}")
          debug_log("request.params['cookies'] IS #{request.params['cookies'].inspect}")

          unless request.post?
            debug_log("request.post? (#{request.post?.inspect}) means passthru")
            return false
          end
          unless request.cookies[COOKIE] != 'accepted'
            debug_log("request.cookies['#{COOKIE}'] (#{request.cookies[COOKIE].inspect}) means passthru")
            return false
          end
          unless request.params['cookies'] == 'accepted'
            debug_log("request.params['cookies'] (#{request.params['cookies'].inspect}) means passthru")
            return false
          end
          debug_log('About to set the acceptance cookie and redirect')
          true
        end

        def debug_log(msg)
          logger.info("[Macmillan::Utils::Middleware::CookieMessage] #{msg}\n")
        end

        def logger
          @logger ||= @request.logger || NullLogger.new
        end

        def redirect_back(request)
          response = Rack::Response.new
          location = build_location(request)

          debug_log("Redirecting to #{location}")

          response.redirect(location)
          response.set_cookie(COOKIE, cookie_options(request))

          response.to_a
        end

        def cookie_options(request)
          {
            value:   'accepted',
            domain:  request.host_with_port,
            path:    '/',
            expires: Time.now.getutc + YEAR
          }
        end

        def build_location(request)
          begin
            debug_log("Attempting to determine redirect by parsing referrer #{request.referrer}")
            uri = URI.parse(request.referrer.to_s)
          rescue URI::InvalidURIError
            debug_log("No that failed, attempting to determine redirect by parsing request.url #{request.url}")
            uri = URI.parse(request.url)
          end

          # Check that the redirect is an internal one for security reasons:
          # https://webmasters.googleblog.com/2009/01/open-redirect-urls-is-your-site-being.html
          unless internal_redirect?(request, uri)
            debug_log("Not internal redirect - so changing to #{request.url} instead of the above")
          end
          internal_redirect?(request, uri) ? uri.to_s : request.url
        end

        def internal_redirect?(request, uri)
          debug_log("Is redirect to #{uri.host}:#{uri.port} internal WRT #{request.host}:#{request.port}")
          request.host == uri.host # && request.port == uri.port
        end

        class NullLogger
          def method_missing(*args)
            nil
          end
        end
      end
    end
  end
end
