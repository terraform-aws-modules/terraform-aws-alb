# Usage Patterns

Various usage patterns are prescribed below.

## Listeners

### Redirect HTTP to HTTPS

The configuration snippet below creates a listener that automatically redirects HTTP/80 requests to HTTPS/443.

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}
```

### Fixed Response

The configuration snippet below creates a listener with a fixed response of `200`.

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    ex-fixed-response = {
      port     = 80
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    }
  }
}
```

## Target Groups

### Instance Target Group

The configuration snippet below creates a target group that targets instances. An example listener is shown to demonstrate how a listener or listener rule can forward traffic to this target group using the target group key of `ex-instance` (this name can be any name that users wish to use).

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    ex-https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]

      forward = {
        # The value of the `target_group_key` is the key used in the `target_groups` map below
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    # This key name is used by the listener/listener rules to know which target to forward traffic to
    ex-instance = {
      name_prefix                       = "h1"
      backend_protocol                  = "HTTP"
      backend_port                      = 80
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = true
    }
  }
}
```

### Lambda Target Group

The configuration snippet below creates two Lambda based target groups. It also demonstrates how users attach permissions to the Lambda function to allow ALB to invoke the function, or they can let ALB attach the necessary permissions to invoke the Lambda function. The listeners specified will split traffic between the two functions, with 60% of traffic going to the Lambda function with invocation permissions, and 40% of traffic going to the Lambda function without invocation permissions.

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    ex-http-weighted-target = {
      port     = 80
      protocol = "HTTP"
      weighted_forward = {
        target_groups = [
          {
            target_group_key = "ex-lambda-with-trigger"
            weight           = 60
          },
          {
            target_group_key = "ex-lambda-without-trigger"
            weight           = 40
          }
        ]
      }
    }
  }

  target_groups = {
    ex-lambda-with-trigger = {
      name_prefix                        = "l1-"
      target_type                        = "lambda"
      lambda_multi_value_headers_enabled = true
      target_id                          = module.lambda_with_allowed_triggers.lambda_function_arn
    }

    ex-lambda-without-trigger = {
      name_prefix              = "l2-"
      target_type              = "lambda"
      target_id                = module.lambda_without_allowed_triggers.lambda_function_arn
      attach_lambda_permission = true
    }
  }
}

module "lambda_with_allowed_triggers" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0"

  # Truncated for brevity ...

  allowed_triggers = {
    AllowExecutionFromELB = {
      service    = "elasticloadbalancing"
      source_arn = module.alb.target_groups["ex-lambda-with-trigger"].arn
    }
  }
}

module "lambda_without_allowed_triggers" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 6.0"

  # Truncated for brevity ...

  # Allowed triggers will be managed by ALB module
  allowed_triggers = {}
}
```

### Target Group without Attachment

The configuration snippet below creates a target group but it does not attach it to anything at this time. This is commonly used with Amazon ECS where ECS will attach the IPs of the ECS Tasks to the target group.

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  target_groups = {
    ex-ip = {
      backend_protocol                  = "HTTP"
      backend_port                      = 80
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }
}
```
