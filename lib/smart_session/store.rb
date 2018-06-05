
require 'base64'
# +SmartSession+ is a session store that strives to correctly handle session storage in the face of multiple
# concurrent actions accessing the session. It is derived from Stephen Kaes' +SqlSessionStore+, a stripped down,
# optimized for speed version of class +ActiveRecordStore+.
#
module SmartSession

  class Store < ActionDispatch::Session::AbstractStore
    include SmartSession::SessionSmarts
    
    # The class to be used for creating, retrieving and updating sessions.
    # Defaults to SmartSession::Session, which is derived from +ActiveRecord::Base+.
    #
    # In order to achieve acceptable performance you should implement
    # your own session class, similar to the one provided for Myqsl.
    #
    # Only functions +find_session+, +create_session+,
    # +update_session+ and +destroy+ are required. See file +mysql_session.rb+.

    cattr_accessor :session_class
    @@session_class = SmartSession::SqlSession
    cattr_accessor :silence_log
    @@silence_log=true

    SESSION_RECORD_KEY = 'rack.session.record'.freeze
      
    def self.session_class= symbol_or_class
      if symbol_or_class.is_a?(Symbol)
        @@session_class = case symbol_or_class
        when :mysql2
          require 'smart_session/mysql2'
          Mysql2Session
        when :postgres
          require 'smart_session/postgresql'
          PostgresqlSession
        when :sqlite
          require 'smart_session/sqlite'
          SqliteSession
        when :mssql
          require 'smart_session/mssql'
          MssqlSession
        else
          raise ArgumentError, "Unknown session class #{symbol_or_class}"
        end
      else
        @@session_class = symbol_or_class
      end
    end

    attr_accessor :silence_logs

    def initialize(app, options={})
      super
    end
    private
    
    def get_session(env, sid)
      if @@silence_log
        ActiveRecord::Base.silence do
          _get_session(env,sid)
        end
      else
        _get_session(env,sid)
      end
    end

    def _get_session(env,sid)
      sid ||= generate_sid
      session = find_session(sid)
      env[SESSION_RECORD_KEY] = session
      [sid, unmarshalize(session.data)]
    end

    def set_session(env, sid, session_data, options)
      if @@silence_log
        ActiveRecord::Base.silence do
          _set_session(env, sid, session_data, options)
        end
      else
        _set_session(env, sid, session_data, options)
      end

      return sid
    end

    def _set_session(env, sid, session_data, options)
      record = get_session_model(env, sid)
      _, session = save_session(record, session_data)
      env[SESSION_RECORD_KEY] = session
    end

    def get_session_model(env, sid)
      if env[Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY][:id].nil?
        env[SESSION_RECORD_KEY] = find_session(sid)
      else
        env[SESSION_RECORD_KEY] ||= find_session(sid)
      end
    end
    
    def find_session(id)
      if @@silence_log
        ActiveRecord::Base.silence do
          _find_session(id)
        end
      else
        _find_session(id)
      end
    end

    def _find_session(id)
      @@session_class.find_session(id) ||
        @@session_class.create_session(id, marshalize({}))
    end
    
    def destroy_session(env, sid, options)
      if @@silence_log
        ActiveRecord::Base.silence do
          _destroy_session(env, sid, options)
        end
      else
        _destroy_session(env, sid, options)
      end
    end

    def _destroy_session(env, sid, options)
      if sid = current_session_id(env)
        get_session_model(env, sid).destroy
        env[SESSION_RECORD_KEY] = nil
      end
      generate_sid unless options[:drop]
    end

  end
end
