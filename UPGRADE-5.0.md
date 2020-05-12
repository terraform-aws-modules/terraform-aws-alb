# Upgrade from v4.x to v5.0

If you have a question regarding this upgrade process, please check code in `examples` directory:

* [Complete Application Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-alb)
* [Complete Network Load Balancer](https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master/examples/complete-nlb)

If you found a bug, please open an issue in this repository.

## List of backward incompatible changes

### Removed resources

1. Removed resources:

    - aws_lb.application_no_logs
    - aws_lb_target_group.main_no_logs
    - aws_lb_listener.frontend_http_tcp_no_logs
    - aws_lb_listener.frontend_https_no_logs
    - aws_lb_listener_certificate.https_listener_no_logs
  
   If you've been using ALB without access logs enabled then you need to run `terraform state mv` to rename resources to new names:
  
    - aws_lb.this
    - aws_lb_target_group.main
    - aws_lb_listener.frontend_http_tcp
    - aws_lb_listener.frontend_https
    - aws_lb_listener_certificate.https_listener

   For example, this command will rename ALB resource: `terraform state mv aws_lb.application_no_logs aws_lb.this`
  
2. Removed variable `target_groups_count`, `http_tcp_listeners_count`, `extra_ssl_certs_count`, `http_tcp_listeners_count`.

3. Removed variable `target_groups_defaults`. Instead, all `health_check` and `stickiness` settings should be implicit for each target group.

# Renamed variables and outputs

1. Renamed logging variables `logging_enabled`, `log_bucket_name`, `log_location_prefix` into a map `access_logs` with keys `enabled`, `bucket`, `prefix`.

2. Renamed variables:

   - `load_balancer_name` => `name`
   - `load_balancer_is_internal` => `internal`
   - `create_alb` => `create_lb`

3. Renamed outputs:

   - `load_balancer_id` => `this_lb_id`
   - `dns_name` => `this_lb_dns_name`
