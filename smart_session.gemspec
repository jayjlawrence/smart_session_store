# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_session/version'

Gem::Specification.new do |gem|
  gem.name          = "smart_session"
  gem.version       = SmartSession::VERSION
  gem.authors       = ["Frederick Cheung"]
  gem.email         = ["frederick.cheung@gmail.com"]
  gem.description   = %q{A session store that avoids the pitfalls usually associated with concurrent access to the session}
  gem.summary       = %q{A session store that avoids the pitfalls usually associated with concurrent access to the session}
  gem.homepage      = ""
  gem.add_dependency "actionpack", '>=3.0.0', '< 4.0.0'
  gem.add_dependency "activerecord", '>=3.0.0', '< 4.0.0'
  gem.add_development_dependency "mysql2", "0.3.17"
  gem.add_development_dependency "sqlite3"
  # gem.add_development_dependency "pg"
  gem.add_development_dependency "sqlserver"
  gem.add_development_dependency "activerecord-sqlserver-adapter"
  gem.add_development_dependency "tiny_tds"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "active_record_query_trace"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
