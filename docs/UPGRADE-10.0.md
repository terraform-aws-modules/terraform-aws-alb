# Upgrade from v9.x to v10.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform `v1.5.7` is now minimum supported version
- AWS provider `v6.5` is now minimum supported version

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used `any` type.
- Security group rules now use a default naming scheme of `<security-group-name>-<map-key>` unless a more specific rule name is provided.
- `rule.actions.type` has been replaced with `rule.actions.<type>`. See before/after below for more details.
- `query_string` supports a list of key:value pairs; type definition updated to support this (i.e. was `map(string)` and is now `list(map(string))`)
- `aws_lb_listener.ssl_policy` now defaults to `ELBSecurityPolicy-TLS13-1-3-2021-06`

### Removed

- None

### Variable and output changes

1. Removed variables:

   - None

2. Renamed variables:

   - None

3. Added variables:

   - None

4. Removed outputs:

   - None

5. Renamed outputs:

   - None

6. Added outputs:

   - None

## Upgrade Migrations

### Diff of Before vs After

```diff
 module "alb" {
   source  = "terraform-aws-modules/alb/aws"
-  version = "9.17.0"
+  version = "10.0.0"

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }

      rules = {
        ex-fixed-response = {
          priority = 3
          actions = [{
            # Same for all action types, not just `fixed_response`
-            type           = "fixed-response"
+            fixed_response = {
               content_type = "text/plain"
               status_code  = 200
               message_body = "This is a fixed response"
+            }
          }]

          conditions = [{
-            query_string = {
+            query_string = [{
              key   = "weighted"
              value = "true"
-            }
+            }]
          }]
        }
      }
    }
  }
}
```

## Terraform State Moves

None required
