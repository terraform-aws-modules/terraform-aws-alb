require 'awspec'
require 'rhcl'

module_vars = Rhcl.parse(File.open('examples/test_fixtures/variables.tf'))
log_location_prefix = module_vars['variable']['log_location_prefix']['default']

tf_state = JSON.parse(File.open('terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate').read)
principal_account_id = tf_state['modules'][0]['outputs']['principal_account_id']['value']
account_id = tf_state['modules'][0]['outputs']['account_id']['value']
vpc_id = tf_state['modules'][0]['outputs']['vpc_id']['value']
security_group_id = tf_state['modules'][0]['outputs']['sg_id']['value']
account_id = tf_state['modules'][0]['outputs']['account_id']['value']
region = tf_state['modules'][0]['outputs']['region']['value']
ENV['AWS_REGION'] = region
# this must match the format in examples/test_fixtures/locals.tf
log_bucket_name = 'logs-' + region + '-' + account_id

describe alb('my-alb') do
  it { should exist }
  its (:load_balancer_name) {should eq 'my-alb'}
  its (:vpc_id) {should eq vpc_id}
  it { should belong_to_vpc('my-vpc') }
  its (:type) {should eq 'application'}
  its (:scheme) {should eq 'internet-facing'}
  its (:ip_address_type) {should eq 'ipv4'}
  it { should have_security_group(security_group_id) }
end

describe alb_target_group('my-alb-tg') do
    it { should exist }
    its(:health_check_path) { should eq '/' }
    its(:health_check_port) { should eq 'traffic-port' }
    its(:health_check_protocol) { should eq 'HTTP' }
    it { should belong_to_alb('my-alb') }
    it { should belong_to_vpc('my-vpc') }
 end

describe s3_bucket(log_bucket_name) do
  it { should exist }
  it { should have_object("#{log_location_prefix}/AWSLogs/#{account_id}/ELBAccessLogTestFile") }
    it do
    should have_policy <<-POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowToPutLoadBalancerLogsToS3Bucket",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::#{principal_account_id}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::#{log_bucket_name}/#{log_location_prefix}/AWSLogs/#{account_id}/*"
        }
    ]
}
    POLICY
  end
end
