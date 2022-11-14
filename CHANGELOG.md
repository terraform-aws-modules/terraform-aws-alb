# Changelog

All notable changes to this project will be documented in this file.

### [8.2.1](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v8.2.0...v8.2.1) (2022-11-14)


### Bug Fixes

* Update CI configuration files to use latest version ([#264](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/264)) ([dd692c7](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/dd692c740690f76808cc055a62335a7080b8242f))

## [8.2.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v8.1.2...v8.2.0) (2022-10-31)


### Features

* Added support for preserve_host_header ([#265](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/265)) ([d69c409](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/d69c4099c9ed38c89b2f4aa6c0684b495d794e8e))

### [8.1.2](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v8.1.1...v8.1.2) (2022-10-28)


### Bug Fixes

* Allow for override of Name tag on load balancer ([#262](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/262)) ([40d10dd](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/40d10dd54c8f4091bdc65f86e5c54e422951101e))

### [8.1.1](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v8.1.0...v8.1.1) (2022-10-28)


### Bug Fixes

* Matched type of extra certificate var in module to type expected in resource ([#259](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/259)) ([144af83](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/144af83cf291dddbc2d424862054ac8d61555c8e))

## [8.1.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v8.0.0...v8.1.0) (2022-09-20)


### Features

* Added connection_termination toggle to target group ([#257](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/257)) ([33b6ecd](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/33b6ecdc0769a63d43dab0b3287fdcecdcb4e805))

## [8.0.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v7.0.0...v8.0.0) (2022-09-16)


### ⚠ BREAKING CHANGES

* Add ip_address_type to target group resource, bumped AWS provider version (#255)

### Features

* Add ip_address_type to target group resource, bumped AWS provider version ([#255](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/255)) ([5d08044](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/5d080446f6e74d6dcbc6ff6110633d3e6e48c909))

## [7.0.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.11.0...v7.0.0) (2022-05-23)


### ⚠ BREAKING CHANGES

* Upgraded Terraform version to 1.0+. Added wrappers. (#249)

### Features

* Upgraded Terraform version to 1.0+. Added wrappers. ([#249](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/249)) ([25d31ee](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/25d31ee31d3a29783568b31dc883eba52de14c9d))

## [6.11.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.10.0...v6.11.0) (2022-05-20)


### Features

* Added support for lambda permissions when the target is a lambda function ([#240](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/240)) ([e79573d](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/e79573d0869ca91fb088e91bc8a3429ecc60c1f8))

## [6.10.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.9.0...v6.10.0) (2022-04-21)


### Features

* Added missing `cookie_name` TG stickiness parameter support ([#245](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/245)) ([a01b7ca](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/a01b7cafa95b9770768a4430630ab0f88379fce8))

## [6.9.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.8.0...v6.9.0) (2022-04-15)


### Features

* Added `weighted-forward` rules for HTTP ([#236](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/236)) ([ba77760](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/ba777608fce8a0fa5307222a9324fa54578ed437))

## [6.8.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.7.0...v6.8.0) (2022-03-12)


### Features

* Made it clear that we stand with Ukraine ([34ba506](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/34ba5062591068c77e2f8dc8c454284bbf039ddd))

## [6.7.0](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.6.1...v6.7.0) (2022-02-04)


### Features

* Add support for enable_waf_fail_open and desync_mitigation_mode ([#235](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/235)) ([a4a79df](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/a4a79dfb66fd868d93b9405617c6ca8938a42893))

## [6.6.1](https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.6.0...v6.6.1) (2021-11-22)


### Bug Fixes

* update CI/CD process to enable auto-release workflow ([#228](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/228)) ([b1100cb](https://github.com/terraform-aws-modules/terraform-aws-alb/commit/b1100cb197e067ee6047ac019a4ed316a82f3786))

<a name="v6.6.0"></a>
## [v6.6.0] - 2021-11-19

- feat: Support weight in forward action ([#224](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/224))


<a name="v6.5.0"></a>
## [v6.5.0] - 2021-08-14

- fix: Remove not required depends_on in aws_lb_target_group ([#215](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/215))


<a name="v6.4.0"></a>
## [v6.4.0] - 2021-08-12

- feat: Add listener rules support for http/tcp listeners ([#216](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/216))


<a name="v6.3.0"></a>
## [v6.3.0] - 2021-07-08

- feat: Add support for preserve_client_ip tg flag ([#213](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/213))


<a name="v6.2.0"></a>
## [v6.2.0] - 2021-06-02

- feat: Adding support for ALPN policies ([#206](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/206))


<a name="v6.1.0"></a>
## [v6.1.0] - 2021-05-15

- feat: Add tags to listener and listener rules ([#199](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/199))
- chore: update CI/CD to use stable `terraform-docs` release artifact and discoverable Apache2.0 license ([#198](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/198))
- chore: Updated versions in README
- chore: Updated versions in README


<a name="v6.0.0"></a>
## [v6.0.0] - 2021-04-26

- feat: Shorten outputs (removing this_) ([#196](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/196))


<a name="v5.16.0"></a>
## [v5.16.0] - 2021-04-16

- fix: Add private_ipv4_address, ipv6_address to subnet_mapping block ([#182](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/182))
- feat: support for target group protocol_version ([#187](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/187))


<a name="v5.15.0"></a>
## [v5.15.0] - 2021-04-15

- fix: Empty target group attachments for Terraform 0.13 ([#194](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/194))


<a name="v5.14.0"></a>
## [v5.14.0] - 2021-04-14

- feat: Add target group attachment capabilities ([#191](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/191))


<a name="v5.13.0"></a>
## [v5.13.0] - 2021-04-06

- chore: Update readme note on S3 access logs bucket creation ([#188](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/188))
- chore: update documentation and pin `terraform_docs` version to avoid future changes ([#190](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/190))


<a name="v5.12.0"></a>
## [v5.12.0] - 2021-03-03

- chore: align ci-cd static checks to use individual minimum Terraform versions ([#185](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/185))
- chore: add ci-cd workflow for pre-commit checks ([#183](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/183))


<a name="v5.11.0"></a>
## [v5.11.0] - 2021-02-20

- chore: update documentation based on latest `terraform-docs` which includes module and resource sections ([#181](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/181))


<a name="v5.10.0"></a>
## [v5.10.0] - 2020-11-24

- fix: Updated supported Terraform versions ([#173](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/173))


<a name="v5.9.0"></a>
## [v5.9.0] - 2020-09-11

- feat: Added listener rules support ([#155](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/155))


<a name="v5.8.0"></a>
## [v5.8.0] - 2020-08-18

- feat: Support Least Outstanding Requests algorithm for load balancing requests ([#158](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/158))


<a name="v5.7.0"></a>
## [v5.7.0] - 2020-08-13

- feat: Support AWS provider 3.0 and Terraform 0.13 ([#166](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/166))


<a name="v5.6.0"></a>
## [v5.6.0] - 2020-05-18

- docs: Updated description and examples of name_prefix argument ([#162](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/162))
- docs: Updated formatting in UPGRADE-5.0.md


<a name="v5.5.0"></a>
## [v5.5.0] - 2020-05-11

- fix: Changed default values for lambda_multi_value_headers_enabled and proxy_protocol_v2from null to false ([#160](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/160))


<a name="v5.4.0"></a>
## [v5.4.0] - 2020-04-13

- feat: Add more specific tags ([#151](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/151))


<a name="v5.3.0"></a>
## [v5.3.0] - 2020-04-04

- feat: Add support for all listener actions (redirect, fixed-response, authenticate-cognito, authenticate-oidc) ([#141](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/141))


<a name="v5.2.0"></a>
## [v5.2.0] - 2020-04-02

- Updated required versions of Terraform
- feat: Add support for drop_invalid_header_fields ([#150](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/150))
- Removed meta github files (see meta repo for more) ([#148](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/148))


<a name="v5.1.0"></a>
## [v5.1.0] - 2020-03-05

- Fixed variable description (closes [#138](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/138))
- Update variables.tf ([#130](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/130))
- Removed unused (depracated) input variable ([#136](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/136))
- Update README.md ([#137](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/137))


<a name="v5.0.0"></a>
## [v5.0.0] - 2019-11-22

- Rewrote to use Terraform 0.12 features + NLB + cleanup ([#128](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/128))
- Set correct TG for listeners (fixed [#119](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/119)) ([#120](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/120))
- Update variables.tf ([#113](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/113))
- Hardcode AWS region for tests
- Remove --error-with-issues option on tflint as it is now default and removed ([#114](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/114))
- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12
- Upgrade module to support Terraform 0.12 ([#107](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/107))


<a name="v3.7.0"></a>
## [v3.7.0] - 2019-11-20

- Set correct TG for listeners for Terraform 0.11 (fixed [#119](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/119)) ([#121](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/121))


<a name="v4.2.0"></a>
## [v4.2.0] - 2019-11-20

- Set correct TG for listeners (fixed [#119](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/119)) ([#120](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/120))
- Update variables.tf ([#113](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/113))
- Hardcode AWS region for tests
- Remove --error-with-issues option on tflint as it is now default and removed ([#114](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/114))


<a name="v4.1.0"></a>
## [v4.1.0] - 2019-06-17

- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12


<a name="v4.0.0"></a>
## [v4.0.0] - 2019-06-11

- Upgrade module to support Terraform 0.12 ([#107](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/107))


<a name="v3.6.0"></a>
## [v3.6.0] - 2019-06-05

- Added create_alb flag ([#104](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/104))


<a name="v3.5.0"></a>
## [v3.5.0] - 2018-12-04

- updated test to remove unsupported attribute
- Add slow_start option
- merge user-provided target_groups_defaults with our defaults
- Add variable to support setting cross-zone-load-balancing ([#73](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/73))
- tidying up
- Move code of conduct to correct file
- Update issue templates


<a name="v3.4.0"></a>
## [v3.4.0] - 2018-05-17

- disabled logging now possible ([#69](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/69))
- Added pre-commit hook to autogenerate terraform-docs ([#68](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/68))


<a name="v3.3.1"></a>
## [v3.3.1] - 2018-05-06

- outputs repaired and tests added to prove counts ([#67](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/67))


<a name="v3.3.0"></a>
## [v3.3.0] - 2018-05-05

- Fix/ci ([#66](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/66))
- tidy up to release ([#65](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/65))
- add output target group arn suffixes ([#64](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/64))
- Revert "Making logging configurable ([#60](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/60))" ([#62](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/62))
- Added missing quotation mark in README.md example ([#63](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/63))
- Making logging configurable ([#60](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/60))


<a name="v3.2.0"></a>
## [v3.2.0] - 2018-03-28

- release of target_group create_before_destroy to allow target_group changes in flight ([#59](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/59))
- create_before_destroy target groups to allow in flight changes ([#58](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/58))


<a name="v3.1.0"></a>
## [v3.1.0] - 2018-03-22

- allow optional extra ssl certs ([#54](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/54))
- `name` moved to `name_prefix` which limits ALB name descriptiveness to 6 characters ([#53](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/53))
- listner » listener (fix typo on outputs.tf) ([#51](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/51))


<a name="v3.0.0"></a>
## [v3.0.0] - 2018-03-20

- 3.0.0 release - configuration supports n of each ancillary ALB resource ([#49](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/49))


<a name="v2.5.0"></a>
## [v2.5.0] - 2018-03-07

- release prep and rubocop compliance ([#48](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/48))
- Adds 2 new variables to control listener ports of ALB
- Add target_group.name to outputs.tf ([#45](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/45))
- update force_destroy_log_bucket description ([#42](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/42))
- fix generated bucket policy if log_location_prefix is omitted (or empty string)
- Add ALB target group target_type variable and  depends_on to alb related resource ([#37](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/37))
- Fix syntax error in usage example ([#39](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/39))


<a name="v2.4.0"></a>
## [v2.4.0] - 2018-01-19

- simple doc update [skip-ci]
- kicking v2.4.0 out the door ([#35](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/35))
- Remove region ([#30](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/30))
- Add deregistration_delay argument ([#34](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/34))
- Alb name ([#28](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/28))
- moved data source to data file


<a name="v2.3.2"></a>
## [v2.3.2] - 2017-12-18

- added version file to help with release tags and changelog
- added changelog entry and applied terraform fmt to updated outputs.tf fiel
- Added http and https listener ARNs ([#25](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/25))
- Create bucket before provisioning access logs on the ALB


<a name="v2.3.1"></a>
## [v2.3.1] - 2017-11-28

- move to kitchen-terraform 3.0.x and terraform 0.11.0 ([#19](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/19))
- Adding the health check code for ALB health checking


<a name="v2.3.0"></a>
## [v2.3.0] - 2017-11-21

- Add ARN of ALB to outputs ([#17](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/17))


<a name="v2.2.0"></a>
## [v2.2.0] - 2017-11-21

- Possible fix for Terraform v0.11(output to non-existing resource)


<a name="v2.1.0"></a>
## [v2.1.0] - 2017-11-17

- added detail to changelog
- resolving the HTTP default issue
- Adding outputs
- Update README.md
- Update README.md
- Update outputs.tf
- Update outputs.tf


<a name="v2.0.0"></a>
## [v2.0.0] - 2017-11-07

- Flip order of variable params, moving versioning to adhere to semver
- Rev'ing minor version as variable changes are breaking
- Added flexibility around logging
- corrected link to CI


<a name="v1.0.3"></a>
## [v1.0.3] - 2017-10-25

- Fixed sid in s3 bucket policy test
- Fixed S3 bucket policy to make it canonical
- Adding CI to module ([#5](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/5))
- Migrating to new org and terraform registry ([#1](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/1))


<a name="v0.0.1"></a>
## v0.0.1 - 2017-09-26

- Initial commit
- Initial commit


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.6.0...HEAD
[v6.6.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.5.0...v6.6.0
[v6.5.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.4.0...v6.5.0
[v6.4.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.3.0...v6.4.0
[v6.3.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.2.0...v6.3.0
[v6.2.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.1.0...v6.2.0
[v6.1.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v6.0.0...v6.1.0
[v6.0.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.16.0...v6.0.0
[v5.16.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.15.0...v5.16.0
[v5.15.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.14.0...v5.15.0
[v5.14.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.13.0...v5.14.0
[v5.13.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.12.0...v5.13.0
[v5.12.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.11.0...v5.12.0
[v5.11.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.10.0...v5.11.0
[v5.10.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.9.0...v5.10.0
[v5.9.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.8.0...v5.9.0
[v5.8.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.7.0...v5.8.0
[v5.7.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.6.0...v5.7.0
[v5.6.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.5.0...v5.6.0
[v5.5.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.4.0...v5.5.0
[v5.4.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.3.0...v5.4.0
[v5.3.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.2.0...v5.3.0
[v5.2.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.1.0...v5.2.0
[v5.1.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v5.0.0...v5.1.0
[v5.0.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.7.0...v5.0.0
[v3.7.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v4.2.0...v3.7.0
[v4.2.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v4.1.0...v4.2.0
[v4.1.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v4.0.0...v4.1.0
[v4.0.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.6.0...v4.0.0
[v3.6.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.5.0...v3.6.0
[v3.5.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.4.0...v3.5.0
[v3.4.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.3.1...v3.4.0
[v3.3.1]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.3.0...v3.3.1
[v3.3.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.2.0...v3.3.0
[v3.2.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.1.0...v3.2.0
[v3.1.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v3.0.0...v3.1.0
[v3.0.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.5.0...v3.0.0
[v2.5.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.4.0...v2.5.0
[v2.4.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.3.2...v2.4.0
[v2.3.2]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.3.1...v2.3.2
[v2.3.1]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.3.0...v2.3.1
[v2.3.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.2.0...v2.3.0
[v2.2.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.1.0...v2.2.0
[v2.1.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v2.0.0...v2.1.0
[v2.0.0]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v1.0.3...v2.0.0
[v1.0.3]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v0.0.1...v1.0.3
