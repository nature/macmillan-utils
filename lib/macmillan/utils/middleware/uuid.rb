require 'securerandom'

module Macmillan
  module Utils
    module Middleware
      ##
      # Rack Middleware for uniquley identifying a user.
      #
      # If the user is logged in, their UUID will be based upon their user_id, otherwise
      # it will be randomly generated.  This UUID will be stored in the rack env, and
      # persisted in a cookie.
      #
      # This middleware expects a user object to be stored in the rack env.
      #
      class Uuid
        def self.env_key
          'user.uuid'
        end

        def initialize(app, opts = {})
          @app            = app
          @user_env_key   = opts[:user_env_key] || 'current_user'
          @user_id_method = opts[:user_id_method] || 'user_id'
        end

        class CallHandler
          attr_reader :app, :request, :user_env_key, :user_id_method, :cookie_key, :rack_errors, :uuid_is_new_key

          def initialize(env, app, user_env_key, user_id_method, cookie_key)
            @app            = app
            @request        = Rack::Request.new(env)
            @user_env_key   = user_env_key
            @user_id_method = user_id_method
            @cookie_key     = cookie_key
            @rack_errors    = env['rack.errors']
            @uuid_is_new_key = "#{cookie_key}_is_new"

            env[cookie_key]      = final_user_uuid
            env[uuid_is_new_key] = true if uuid_is_new?
          end

          def finish
            save_cookie if store_cookie?
            clean_old_cookies
            response.finish
          end

          private

          def response
            @response ||= begin
                            status, headers, body = app.call(request.env)
                            Rack::Response.new(body, status, headers)
                          end
          end

          def user
            request.env[user_env_key]
          end

          def user_hexdigest
            Digest::SHA1.hexdigest(user.public_send(user_id_method).to_s) if user
          end

          def final_user_uuid
            @final_user_uuid ||= user_hexdigest || uuid_from_cookies || SecureRandom.uuid
          end

          def uuid_from_cookies
            request.cookies[cookie_key]
          end

          def store_cookie?
            final_user_uuid != uuid_from_cookies
          end
          alias_method :uuid_is_new?, :store_cookie?

          def save_cookie
            cookie_value = { value: final_user_uuid, path: '/', expires: DateTime.now.next_year.to_time }
            response.set_cookie(cookie_key, cookie_value)
          end

          def clean_old_cookies
            response.delete_cookie('bandiera.uuid') if request.cookies['bandiera.uuid']
            response.delete_cookie('sherlock.uuid') if request.cookies['sherlock.uuid']
            response.delete_cookie('sixpack.uuid') if request.cookies['sixpack.uuid']
          end
        end

        def call(env)
          dup.process(env)
        end

        def process(env)
          handler = CallHandler.new(env, @app, @user_env_key, @user_id_method, self.class.env_key)
          handler.finish
        end
      end
    end
  end
end
