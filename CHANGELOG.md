<a name="unreleased"></a>
## [Unreleased]



<a name="v4.1.0"></a>
## [v4.1.0] - 2019-06-17

- Updated pre-commit-terraform to support terraform-docs and Terraform 0.12


<a name="v4.0.0"></a>
## [v4.0.0] - 2019-06-11

- Updated CHANGELOG
- Upgrade module to support Terraform 0.12 ([#107](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/107))


<a name="v3.6.0"></a>
## [v3.6.0] - 2019-06-05

- Added create_alb flag ([#104](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/104))


<a name="v3.5.0"></a>
## [v3.5.0] - 2018-12-04

- Merge pull request [#91](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/91) from terraform-aws-modules/fix/tests
- updated test to remove unsupported attribute
- Merge pull request [#87](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/87) from jwhitcraft/slow_start
- Add slow_start option
- Merge pull request [#81](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/81) from alkalinecoffee/master
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
- Merge pull request [#47](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/47) from egarbi/custom_alb_listener_ports
- Adds 2 new variables to control listener ports of ALB
- Merge pull request [#41](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/41) from angstwad/fix-bucket-policy
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
- Merge pull request [#18](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/18) from mbolek/tg_health_code
- Adding the health check code for ALB health checking


<a name="v2.3.0"></a>
## [v2.3.0] - 2017-11-21

- Add ARN of ALB to outputs ([#17](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/17))


<a name="v2.2.0"></a>
## [v2.2.0] - 2017-11-21

- Merge pull request [#16](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/16) from mbolek/terraform_v011
- Possible fix for Terraform v0.11(output to non-existing resource)


<a name="v2.1.0"></a>
## [v2.1.0] - 2017-11-17

- Merge pull request [#14](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/14) from terraform-aws-modules/simplify_region_var_in_tests
- added detail to changelog
- resolving the HTTP default issue
- Merge pull request [#13](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/13) from mbolek/alb_listener_outputs
- Adding outputs
- Merge pull request [#10](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/10) from tpoindessous/patch-2
- Merge pull request [#9](https://github.com/terraform-aws-modules/terraform-aws-alb/issues/9) from tpoindessous/patch-1
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


[Unreleased]: https://github.com/terraform-aws-modules/terraform-aws-alb/compare/v4.1.0...HEAD
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
