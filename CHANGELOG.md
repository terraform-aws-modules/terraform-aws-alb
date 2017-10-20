# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

<<<<<<< HEAD
## [1.0.3] - 2017-10-19
## Added
* TravisCI configuration added and now passing.
* badge added to docs.
* permissions section now in the example readme.
* placeholder shell script added for CI deployment. Eventually this should conditionally release to the registry when those APIs become available.

## Changed
* altered tf variable `aws_region` to `region`.
* replaced hardcoding the region to instead use a random region as retrieved by an awscli docker container within CI.
* example cert is now a regionally-specific resource enabling tests to run in various regions at once and not collide.
* ruby version bump means `Rhcl` becomes `rhcl`.

=======
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb
## [1.0.2] - 2017-10-12
### Added
* moved data sources to dedicated `data.tf` file.
* `aws_caller_identity` now used to gather account_id rather than using a variable.
* tests added for `target_group` and expanded for `alb`.
* input variables added for health checks, bucket policy, force_destroy_log_bucket - increasing flexibility.
<<<<<<< HEAD
=======
* circle CI config and badge
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb

### Changed
* altered structure of module to conform to the new [Terraform registry standards](https://www.terraform.io/docs/registry/modules/publish.html#requirements)
* `principle_account_id` (sp) moved to a data source rather than variable map. Spelling corrected.
* removed redundant `/test/alb` directory which had module contents copied. Test kitchen now uses the module itself.
* pinned examples to provider and terraform versions to harden versioning.
* self signed cert added to the test fixtures, eliminating the need for manual upload and terraform.tfvars configuration.
* modules referenced in the test fixture are now sourced from the terraform registry.
<<<<<<< HEAD
* removed bucket_policy.json in favor of creating the policy via the `aws_iam_policy_document` resource or optionally a variable.
* stringed list variables moved to native lists
=======
* moved bucket_policy.json and template rending to locals + optional variable input.
* stringed list variables moved to native lists
*
>>>>>>> b5a4c76cab7e5471f5af210fb858c42787453ebb

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
