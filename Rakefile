require 'fileutils'
require 'json'

CACHE_DIR = ENV["SNAP_CACHE_DIR"] || '/tmp'
RUBY_BUILD_PACK_VERSION = "ruby-2.0.0"
RUBY_BUILD_PACK_FILE =  "#{RUBY_BUILD_PACK_VERSION}.tgz"

APP_NAME = ENV['HEROKU_APP_NAME'] || 'mavcunha-slug'

task :default => [:build]

task :cache_buildpack do
  Dir.chdir(CACHE_DIR) do
    sh "curl -sS https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/#{RUBY_BUILD_PACK_FILE} -o \"#{RUBY_BUILD_PACK_FILE}\" " unless File.exists? RUBY_BUILD_PACK_FILE
  end
end

task :get_buildpack => :cache_buildpack do
  Dir.chdir('app') do
    ensure_dir RUBY_BUILD_PACK_VERSION
    sh "tar xzvf #{File.join(CACHE_DIR, RUBY_BUILD_PACK_FILE)} -C #{RUBY_BUILD_PACK_VERSION}"
  end
end

task :build => [:clean, :get_buildpack] do
  ensure_dir 'target'
  sh "tar czfv target/slug.tgz ./app"
end

task :new_slug do
  ensure_dir 'target'
  cmd = %W(
    curl -sS -X POST
      -H 'Content-Type: application/json'
      -H 'Accept: application/vnd.heroku+json; version=3'
      -d '{"process_types":{"web": "ruby-2.0.0/bin/ruby server.rb"}}'
      -n https://api.heroku.com/apps/#{APP_NAME}/slugs
  )
  data = JSON.parse(%x(#{cmd.join(' ')}))

  puts "saving slug id and slug url"

  write_file 'target/slug_id',  data["id"]
  write_file 'target/slug_url', data["blob"]["url"]
end

task :upload_slug => :new_slug do
  cmd = %W(
    curl -sS -X PUT
      -H "Content-Type:"
      --data-binary @target/slug.tgz
      "#{slug_url}")
  puts %x(#{cmd.join ' '}))
end

task :release_slug do
  cmd = %W(
    curl -sS -X POST
      -H "Accept: application/vnd.heroku+json; version=3"
      -H "Content-Type: application/json"
      -d '{"slug":"#{slug_id}"}'
      -n https://api.heroku.com/apps/#{APP_NAME}/releases)
  %x(#{cmd.join ' '})
end

task :clean do
  FileUtils.rm_rf 'target'
  FileUtils.rm_rf "app/#{RUBY_BUILD_PACK_VERSION}"
end

def write_file(filename, content)
  File.open(filename, 'w') do |f|
    f.puts content
  end
end

def slug_id
  File.read('target/slug_id').chomp
end

def slug_url
  File.read('target/slug_url').chomp
end

def ensure_dir(dir)
  FileUtils.mkdir dir unless Dir.exists? dir
end
