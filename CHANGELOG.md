# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## [[vNEXT](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.5.0...HEAD)] - yyyy-mm-dd]

## [[v3.5.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.4.0...v3.5.0)] - 2018-12-03]

### Changed

- `slow_start` now exposed as a variable (thanks, @jwhitcraft 🥝)
- `terraform-docs` doc generation process (and docs) updated as for the latest version.
- tests repaired

## [[v3.4.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.3.1...v3.4.0)] - 2018-05-17]

### Changed

- resources supporting the not logging scenario added. Outputs now accommodate.
- reorganized the resource explosion to separate files.
- tests reorganized to confine cruft.
- `terraform-docs` now supported and generating documentation. (Kiitos, @antonbabenko 🍒)

## [[v3.3.1](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.3.0...v3.3.1)] - 2018-05-06]

### Changed

- sliced outputs were appended with a `- 1` in debugging. This introduced a bug which was fixed and verified through test.

## [[v3.3.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.2.0...v3.3.0)] - 2018-05-04]

### Added

- `target_group_arn_suffixes` added to support monitoring through CloudWatch (props, @jeff-everett 🤗)
- Contributor Covenant gives guidelines on contributions.
- Issues and PR templates.

## [v3.2.0] - 2018-03-28

### Changed

- `create_before_destroy` lifecycle policy added to the target groups. This allows target groups to be modified, though means they're recreated anytime they're changed. A change MUST include a change to the `name` value or will fail on duplicates. (nice work, @egarbi 🦄)

## [v3.1.0] - 2018-03-22

### Added

- extra certs can now be applied to HTTPS listeners via the `extra_ssl_certs` list variable and corresponding `extra_ssl_certs_count`.

### Changed

- `load_balancer_security_groups` moved to simpler `security_groups`.
- `name_prefix` changed back to `name` as the inflexibility of a 6 character prefix is overly restricting. Name conflicts must be dealt with by the developer. (cheers, @michaelmoussa 🎉)
- upgraded terraform and kitchen terraform. terraform 0.11.4 and above errors out on warnings but has been mitigated with `TF_WARN_OUTPUT_ERRORS=1` per [this issue](https://github.com/hashicorp/terraform/issues/17655).

## [v3.0.0] - 2018-03-20

### Added

- default values added for most target group and listener attributes.
- new application load balancer attributes added as variables with defaults.
- tests now cover listeners.

### Changed

- listeners and target groups now defined by lists of maps allowing many-to-many relationships of those resources.
- listeners and target groups creation is now data driven through variables giving greater flexibility.
- `name_prefix` used where possible to avoid naming conflicts in resource testing.
- logging to S3 now made manditory and done outside the module as this is better practice. (thanks, @alexjurkiewicz 🥂)
- terraform 0.11.3 now used in CI. 0.11.4 seems to have warnings on plan that become errors in CI.

## [v2.5.0] - 2018-03-07

### Added

- `target_type` variable for targeting IPs rather than instances (nice, @angusfz 👌)
- Added variables for controlling front door ALB listening ports (thanks, @egarbi ✨)
- output for `target_group_name` for external consumption (boom! @ndench 🐱‍🐉)

### Changed

- Clarified variable description and bucket policy (right on, @angstwad 👏)
- Docs and var description updates (everything helps, @tehmaspc 🦑)

## [v2.4.0] - 2018-01-19

### Added

- `alb_arn_suffix` output added for external consumption. (props, @mbolek 🐱‍🏍)
- variables to control listener ports (wunderbar, @egarbi 🙌)

### Changed

- Remove `region` input. If you'd like to customise the AWS provider configuration,
  this is supported using the new `providers` input which is a core Terraform feature.
  [Read more.](https://www.terraform.io/docs/modules/usage.html#providers-within-modules)
- update CI to use terraform 0.11.2 and KT 3.1.0.
- Several formatting changes to adhere to convention.

## [v2.3.2] - 2017-12-18

### Added

- ARN outputs of listeners for reuse outside the module. (thanks, @proj4spes! 👌)

## [v2.3.1] - 2017-11-27

### Added

- variable `health_check_matcher` determines a set or range of successful HTTP
  status codes for target group health checks (🧀 @mbolek).
- adapted test kitchen configuration to KT 3.0.x.

## [v2.1.0] - 2017-11-16

### Added

- outputs added for listeners - these can be useful for ECR integration (🍰
  @mbolek).
- Moved default `alb_protocols` to HTTP to lower barier of entry in getting
  started.

## [v2.0.0] - 2017-11-06

### Added

- added `create_log_bucket` and `enable_logging` to help control logging more
  granularly.

### Changed

- existing log-related variables made more descriptive (this is the breaking
  change)
- S3 policy related test made more explicit (⭐ @antonbabenko)

## [v1.0.3] - 2017-10-19

### Added

- TravisCI configuration added and now passing.
- badge added to docs.
- permissions section now in the example readme.
- placeholder shell script added for CI deployment. Eventually this should
  conditionally release to the registry when those APIs become available.

### Changed

- altered tf variable `aws_region` to `region`.
- replaced hardcoding the region to instead use a random region as retrieved by
  an awscli docker container within CI.
- example cert is now a regionally-specific resource enabling tests to run in
  various regions at once and not collide.
- ruby version bump means `Rhcl` becomes `rhcl`.

## [v1.0.2] - 2017-10-12

### Added

- moved data sources to dedicated `data.tf` file.
- `aws_caller_identity` now used to gather account_id rather than using a
  variable.
- tests added for `target_group` and expanded for `alb`.
- input variables added for health checks, bucket policy,
  force_destroy_log_bucket - increasing flexibility.

### Changed

- altered structure of module to conform to the new
  [Terraform registry standards](https://www.terraform.io/docs/registry/modules/publish.html#requirements)
- `principle_account_id` (sp) moved to a data source rather than variable map.
  Spelling corrected.
- removed redundant `/test/alb` directory which had module contents copied. Test
  kitchen now uses the module itself.
- pinned examples to provider and terraform versions to harden versioning.
- self signed cert added to the test fixtures, eliminating the need for manual
  upload and terraform.tfvars configuration.
- modules referenced in the test fixture are now sourced from the terraform
  registry.
- removed bucket_policy.json in favor of creating the policy via the
  `aws_iam_policy_document` resource or optionally a variable.
- stringed list variables moved to native lists

## [v1.0.1] - 2017-09-14

### Added

- tag maps can now be provided (thanks @kwach)

### Changed

- optional S3 logging (thanks @marocchino)

## [v1.0.0] - 2017-03-16

### Added

- Tests and fixtures for ALB components using awspec and test kitchen
- S3 log bucket and policy rendering for logging now in place
- root_principle_id added and referenced through a map for s3 bucket policy
- string lists moved to native list types
- default region removed

### Changed

- Restructured project templates to alb dir to add testing. This is a breaking
  change so upping major version.
- Redundant examples dir removed
- Updated documentation

## [v0.1.0] - 2017-03-09

### Added

- Initial release.
