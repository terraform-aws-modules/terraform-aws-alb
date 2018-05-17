# frozen_string_literal: true

require 'awspec'
require_relative 'setup'

describe alb(ALB_NAME) do
  it { should exist }
  its(:load_balancer_name) { should eq ALB_NAME }
  its(:vpc_id) { should eq VPC_ID }
  it { should belong_to_vpc('test-vpc') }
  its(:type) { should eq 'application' }
  its(:scheme) { should eq 'internet-facing' }
  its(:ip_address_type) { should eq 'ipv4' }
  it { should have_security_group(SECURITY_GROUP_ID) }
end

describe alb_target_group('foo') do
  its(:port) { should eq 80 }
end

describe alb_target_group('bar') do
  its(:port) { should eq 8080 }
end

@target_group_arns.each do |tg_arn|
  tg_name = tg_arn.split('/')[-2]
  describe alb_target_group(tg_name) do
    it { should exist }
    it { should belong_to_alb(ALB_NAME) }
    it { should belong_to_vpc('test-vpc') }
    its(:protocol) { should eq 'HTTP' }
    its(:health_check_protocol) { should eq 'HTTP' }
    its(:health_check_interval_seconds) { should eq 10 }
    its(:health_check_timeout_seconds) { should eq 5 }
    its(:healthy_threshold_count) { should eq 3 }
    its(:health_check_path) { should eq '/' }
    its(:unhealthy_threshold_count) { should eq 3 }
    its(:target_type) { should eq 'instance' }
    its(:health_check_port) { should eq 'traffic-port' }
  end
end

@https_listener_arns.each do |listener|
  describe alb_listener(listener) do
    it { should exist }
    its(:protocol) { should eq 'HTTPS' }
    its(:port) { should eq(443).or(eq(8443)) }
  end
end

@http_tcp_listener_arns.each do |listener|
  describe alb_listener(listener) do
    it { should exist }
    its(:protocol) { should eq 'HTTP' }
    its(:port) { should eq(80).or(eq(8080).or(eq(8081))) }
  end
end

@count_cases.each do |test_case|
  describe test_case[0] do
    it 'should be predetermined length' do
      expect(test_case[0].length).to eq(test_case[1].to_i)
    end
  end
end
