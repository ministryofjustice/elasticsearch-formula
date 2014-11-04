require 'serverspec'
require 'net/http'
require 'uri'

set :backend, :exec

set :path, '/sbin:/usr/local/sbin:$PATH'

describe "elasticsearch setup" do

  describe file("/etc/elasticsearch") do
    it {should be_directory}
    it {should be_mode 750}
    it {should be_owned_by "root"}
    it {should be_grouped_into "elasticsearch"}
  end

  describe file("/etc/elasticsearch/elasticsearch.yml") do
    it {should be_file}
    it {should be_mode 640}
    it {should be_owned_by "root"}
    it {should be_grouped_into "elasticsearch"}
  end

  describe file("/etc/default/elasticsearch") do
    it {should be_file}
    it {should be_mode 640}
    it {should be_owned_by "root"}
    it {should be_grouped_into "root"}
    its(:content) { should match /^ES_HEAP_SIZE=512m$/}
  end

  es_pkg = {
    "name" => "elasticsearch",
    "version" => "1.3.1"
  }

  describe package(es_pkg["name"]) do
    it {should be_installed.with_version(es_pkg["version"])}
  end

  describe command("sysctl -a") do
    its(:stdout) { should match /^vm\.max_map_count = 262144$/}
  end

  es_listen = {
    "http" => 9200,
    "tcp" => 9300
  }

  describe service("elasticsearch") do
    it { should be_enabled }
    it { should be_running }
  end

  es_listen.each do |proto, port|
    describe port(port) do
      it { should be_listening }
    end

    describe iptables do
      it { should have_rule("-A INPUT -p tcp -m tcp --dport #{port} -m comment --comment elasticsearch-#{proto}-tcp-#{port} -j ACCEPT") }
    end
  end

  describe "ES cluster health" do
    uri = URI.parse("http://localhost:#{es_listen["http"]}/_cluster/health")
    resp = Net::HTTP.get_response(uri)
    it "should be healthy" do
      resp.code == 200
    end
  end

end
