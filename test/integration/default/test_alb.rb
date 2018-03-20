# frozen_string_literal: true

require 'awspec'
require 'rhcl'

module_vars = Rhcl.parse(File.open('examples/alb_test_fixture/variables.tf'))
log_location_prefix = module_vars['variable']['log_location_prefix']['default']

# rubocop:disable LineLength
state_file = 'terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate'
tf_state = JSON.parse(File.open(state_file).read)
http_tcp_listener_arns = tf_state['modules'][0]['outputs']['http_tcp_listener_arns']['value']
https_listener_arns = tf_state['modules'][0]['outputs']['https_listener_arns']['value']
# rubocop:enable LineLength
alb_arn = tf_state['modules'][0]['outputs']['alb_id']['value']
alb_name = alb_arn.split('/')[-2]
account_id = tf_state['modules'][0]['outputs']['account_id']['value']
region = tf_state['modules'][0]['outputs']['region']['value']
ENV['AWS_REGION'] = region
vpc_id = tf_state['modules'][0]['outputs']['vpc_id']['value']
security_group_id = tf_state['modules'][0]['outputs']['sg_id']['value']

describe alb(alb_name) do
  it { should exist }
  its(:load_balancer_name) { should eq alb_name }
  its(:vpc_id) { should eq vpc_id }
  it { should belong_to_vpc('test-vpc') }
  its(:type) { should eq 'application' }
  its(:scheme) { should eq 'internet-facing' }
  its(:ip_address_type) { should eq 'ipv4' }
  it { should have_security_group(security_group_id) }
end

describe alb_target_group('foo') do
  it { should exist }
  its(:health_check_path) { should eq '/' }
  its(:health_check_port) { should eq 'traffic-port' }
  its(:health_check_protocol) { should eq 'HTTP' }
  it { should belong_to_alb(alb_name) }
  it { should belong_to_vpc('test-vpc') }
end

puts http_tcp_listener_arns
puts https_listener_arns
# describe alb_listener(alb_arn) do
#   it { should exist }
#   its(:port) { should eq 80 }
#   its(:protocol) { should eq 'HTTPS' }
# end
