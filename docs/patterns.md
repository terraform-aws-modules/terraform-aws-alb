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
    http_https_redirect = {
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
    fixed_response = {
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

### Auth0 authenticated HTTPS Listener

The configuration snippet below creates an HTTPS listener that utilizes [Auth0](https://www.auth0.com) to secure access. Read more in [this post](https://medium.com/@sandrinodm/securing-your-applications-with-aws-alb-built-in-authentication-and-auth0-310ad84c8595).

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    https_auth0 = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:eu-west-1:135367859851:certificate/70e008e1-c0e1-4c7e-9670-7bb5bd4f5a84"

      authenticate_oidc = {
        issuer                              = "https://youruser.eu.auth0.com/"
        token_endpoint                      = "https://youruser.eu.auth0.com/oauth/token"
        user_info_endpoint                  = "https://youruser.eu.auth0.com/userinfo"
        authorization_endpoint              = "https://youruser.eu.auth0.com/authorize"
        authentication_request_extra_params = {}
        client_id                           = "clientid"
        client_secret                       = "secret123" # a data source would be good here
      }
    }
  }
}
```

### Okta authenticated HTTPS Listener

The configuration snippet below creates an HTTPS listener that utilizes [Okta](https://www.okta.com/) to secure access. Read more in [this post](https://medium.com/swlh/aws-alb-authentication-with-okta-oidc-using-terraform-902cd8289db4).

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    https_okta = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:eu-west-1:135367859851:certificate/70e008e1-c0e1-4c7e-9670-7bb5bd4f5a84"

      authenticate_oidc = {
        issuer                              = "https://dev-42069.okta.com/"
        token_endpoint                      = "https://dev-42069.okta.com/oauth2/v1/token"
        user_info_endpoint                  = "https://dev-42069.okta.com/oauth2/v1/userinfo"
        authorization_endpoint              = "https://dev-42069.okta.com/oauth2/v1/authorize"
        authentication_request_extra_params = {}
        client_id                           = "clientid"
        client_secret                       = "secret123" # a data source would be good here
      }
    }
  }
}
```

### Google authenticated HTTPS Listener

The configuration snippet below creates an HTTPS listener that utilizes Google to secure access. See the [iap_client resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client) in the Google provider if you want to create this configuration in Terraform. Remember to set your google consent screen to internal to only allow users from your own domain.

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    https_google = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:eu-west-1:135367859851:certificate/70e008e1-c0e1-4c7e-9670-7bb5bd4f5a84"

      authenticate_oidc = {
        issuer                              = "https://accounts.google.com"
        token_endpoint                      = "https://oauth2.googleapis.com/token"
        user_info_endpoint                  = "https://openidconnect.googleapis.com/v1/userinfo"
        authorization_endpoint              = "https://accounts.google.com/o/oauth2/v2/auth"
        authentication_request_extra_params = {}
        client_id                           = "google_client_id"
        client_secret                       = "google_client_secret"
      }
    }
  }
}
```

### Amazon Cognito authenticated HTTPS Listener

The configuration snippet below creates an HTTPS listener that utilizes [Amazon Cognito](https://aws.amazon.com/cognito/) to secure access. See the [iap_client resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client) in the Google provider if you want to create this configuration in Terraform. Remember to set your google consent screen to internal to only allow users from your own domain.

```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  listeners = {
    https_cognito = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:eu-west-1:135367859851:certificate/70e008e1-c0e1-4c7e-9670-7bb5bd4f5a84"

      authenticate_cognito = {
        user_pool_arn       = "arn:aws:cognito-idp:eu-west-1:1234567890:userpool/eu-west-1_aBcDeFG"
        user_pool_client_id = "clientid123"
        user_pool_domain    = "sso.your-corp.com"
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
    ex_https = {
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
    ex_instance = {
      name_prefix                       = "h1"
      protocol                          = "HTTP"
      port                              = 80
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
    http_weighted_target = {
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
    lambda_with_trigger = {
      name_prefix                        = "l1-"
      target_type                        = "lambda"
      lambda_multi_value_headers_enabled = true
      target_id                          = module.lambda_with_allowed_triggers.lambda_function_arn
    }

    lambda_without_trigger = {
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
    ex_ip = {
      protocol                          = "HTTP"
      port                              = 80
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

### Multiple Target Groups with For Loop

The configuration snippet below creates two target groups using a for loop. This is useful to provision multiple different target groups with similar configurations at scale. The for loop will iterate over the `local.services` map definition and create corresponding `target_groups` map with the same key names and associated values.

```hcl
local {
  services = {
    blue = {
      path = "/"
      port = 80
    }
    green = {
      path = "/"
      port = 80
    }
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  # Truncated for brevity ...

  target_groups = {
    for key, value in local.services : key => {
      name              = key
      port              = value.port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        path = value.path
      }
    }
  }
}
```
