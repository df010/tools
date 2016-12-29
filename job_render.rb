#!/usr/bin/env ruby
require 'erb'
require 'yaml'
require 'json'
require 'bosh/template/renderer'
require 'bosh/template/evaluation_context'
require 'fileutils'

JOB_FOLDER=ARGV[0]
PROP_FILE=ARGV[1]
spec_content=YAML.load_file JOB_FOLDER+'/spec'

FileUtils.mkdir_p JOB_FOLDER+'/tmp'


def local_var props, name, value
  if props[name].nil?
    props[name]=value
  end
  props[name]
end

def set_var props, name, value
  parts=name.split(".")
  parentVar=nil
  if(parts.length == 1)
    parentVar=local_var props, parts[0], value
    # puts bnd.local_variable_get(parts[0]).to_s
    return
  else
    parentVar=local_var props, parts[0], {}
  end


  for i in 1..(parts.length-2)
    if parentVar[parts[i]].nil?
      parentVar[parts[i]]={}
    end
    parentVar=parentVar[parts[i]]
  end

  parentVar[parts[parts.length-1]]=value
end

# template = "Hello <%= planet_name %>"
# # binding.eval("planet_name=3");
# bnd=get_bnd
spec = {
    'job' => {
        'name' => 'foobar'
    },
    'properties' => {
    },
    # 'links' => {
    #     'fake-link-1' => {'instances' => [{'name' => 'link_name', 'address' => "123.456.789.101", 'properties' => {'prop1' => 'value'}}]},
    #     'fake-link-2' => {'instances' => [{'name' => 'link_name', 'address' => "123.456.789.102", 'properties' => {'prop2' => 'value'}}]}
    # },
    'networks' => {
        'network1' => {
            'foo' => 'bar',
            'ip' => '192.168.0.1'
        },
        'network2' => {
            'baz' => 'bang',
            'ip' => '10.10.10.10'
        },
    },
    'index' => 0,
    'id' => 'deadbeef',
    'bootstrap' => true,
    'az' => 'foo-az',
    'resource_pool' => {
        'cloud_properties' => {
            'ram'=> 128
        }
    }
}
#
if !PROP_FILE.nil?
  spec['properties']=YAML.load_file PROP_FILE
end

if !spec_content['properties'].nil?
  spec_content['properties'].each do |key, val|
    if(!val['default'].nil?)
      set_var spec['properties'], key, val['default']
    # else
    #   set_var spec['properties'], key, "..."
    end
  end
end

puts spec.to_s

context =Bosh::Template::EvaluationContext.new(spec).to_s
spec_content['templates'].each do |key, value|
  render=Bosh::Template::Renderer.new  :context => spec.to_json
  res=render.render(JOB_FOLDER+"/templates/"+key)
  puts (JOB_FOLDER+"/tmp/"+value).to_s
  FileUtils.mkdir_p (JOB_FOLDER+"/tmp/"+value).gsub(/(.*)\/[^\/]*/, '\1')
  File.open(JOB_FOLDER+"/tmp/"+value,'w') {|file|
    file.write(res);
  }
end
