# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.2] - 2017-10-12
### Added
* moved data sources to dedicated `data.tf` file.
* `aws_caller_identity` now used to gather account_id rather than using a variable.
* tests added for `target_group` and expanded for `alb`.
* input variables added for health checks, bucket policy, force_destroy_log_bucket - increasing flexibility.
* TravisCI configuration and badge.

### Changed
* altered structure of module to conform to the new [Terraform registry standards](https://www.terraform.io/docs/registry/modules/publish.html#requirements)
* `principle_account_id` (sp) moved to a data source rather than variable map. Spelling corrected.
* removed redundant `/test/alb` directory which had module contents copied. Test kitchen now uses the module itself.
* pinned examples to provider and terraform versions to harden versioning.
* self signed cert added to the test fixtures, eliminating the need for manual upload and terraform.tfvars configuration.
* modules referenced in the test fixture are now sourced from the terraform registry.
* moved bucket_policy.json and template rending to locals + optional variable input.
* stringed list variables moved to native lists

## [1.0.1] - 2017-09-14
### Added
* tag maps can now be provided (thanks @kwach)

### Changed
* optional S3 logging (thanks @marocchino)

## [1.0.0] - 2017-03-16
### Added
* Tests and fixtures for ALB components using awspec and test kitchen
* S3 log bucket and policy rendering for logging now in place
* root_principle_id added and referenced through a map for s3 bucket policy
* string lists moved to native list types
* default region removed

### Changed
* Restructured project templates to alb dir to add testing. This is a breaking change so upping major version.
* Redundant examples dir removed
* Updated documentation

## [0.1.0] - 2017-03-09
### Added
* Initial release.
