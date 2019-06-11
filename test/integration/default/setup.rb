# frozen_string_literal: true

# rubocop:disable LineLength
state_file = 'examples/alb_test_fixture/terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate'
tf_state = JSON.parse(File.open(state_file).read)
@http_tcp_listener_arns = tf_state['outputs']['http_tcp_listener_arns']['value']
@https_listener_arns = tf_state['outputs']['https_listener_arns']['value']
@target_group_arns = tf_state['outputs']['target_group_arns']['value']
@http_tcp_listeners_count = tf_state['outputs']['http_tcp_listeners_count']['value']
@https_listeners_count = tf_state['outputs']['https_listeners_count']['value']
@target_groups_count = tf_state['outputs']['target_groups_count']['value']
# rubocop:enable LineLength
@alb_arn = tf_state['outputs']['alb_id']['value']
ALB_NAME = @alb_arn.split('/')[-2]
@region = tf_state['outputs']['region']['value']
ENV['AWS_REGION'] = @region
VPC_ID = tf_state['outputs']['vpc_id']['value']
SECURITY_GROUP_ID = tf_state['outputs']['sg_id']['value']
@count_cases = [[@target_group_arns, @target_groups_count],
               [@http_tcp_listener_arns, @http_tcp_listeners_count],
               [@https_listener_arns, @https_listeners_count]]
