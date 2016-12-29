#!/usr/bin/env ruby
require 'erb'
require 'yaml'
require 'json'
require 'bosh/template/renderer'
require 'bosh/template/evaluation_context'
require 'fileutils'

RELEASE_FOLDER=ARGV[0]
BLOB_CONF=YAML.load_file RELEASE_FOLDER+'/config/blobs.yml'
# FileUtils.mkdir_p JOB_FOLDER+'/tmp'
result=[]
Dir.glob(RELEASE_FOLDER+"/.blobs/*").each {|file|
  result.push(File.stat(file).size.to_s)
}

BLOB_CONF.each do |key, value|
  if(result.delete(value['size'].to_s).nil? )
    puts "different: "+key.to_s+"  "+value['size'].to_s
  end
end

#

