#
# Cookbook Name:: percona
# Recipe:: percona_repo
#

compile_time = node['percona']['compile_time']

Chef::Log.info("Compile time: #{compile_time}")

case node["platform_family"]
when "debian"
  include_recipe "apt"

  resource = apt_repository "percona" do
    uri "http://repo.percona.com/apt"
    distribution node["lsb"]["codename"]
    components ["main"]
    keyserver node["percona"]["keyserver"]
    key "1C4CBDCDCD2EFD2A"
    action ( compile_time ? :nothing : :add )
    notifies :run, "execute[apt-get update]", :immediately
  end
  resource.run_action :add if compile_time
  
  # Pin this repo as to avoid conflicts with others
  apt_preference "00percona" do
    package_name "*"
    pin " release o=Percona Development Team"
    pin_priority "1001"
  end
  

  # install dependent package
  package "libmysqlclient-dev" do
    options "--force-yes"
  end

when "rhel"
  include_recipe "yum"
  resource = yum_key "RPM-GPG-KEY-percona" do
    url "http://www.percona.com/downloads/RPM-GPG-KEY-percona"
    action ( compile_time ? :nothing : :add )
  end
  resource.run_action :add if compile_time

  resource = yum_repository "percona" do
    name "CentOS-Percona"
    url "http://repo.percona.com/centos/#{node["platform_version"].split('.')[0]}/os/#{node["kernel"]["machine"]}/"
    key "RPM-GPG-KEY-percona"
    make_cache true
    action ( compile_time ? :nothing : :add )
  end
  resource.run_action :add if compile_time
end
