package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestSimpleAlbAttach(t *testing.T) {
	t.Parallel()

	expectedName := fmt.Sprintf("vpc-terratest-%s", strings.ToLower(random.UniqueId()))
	ec2Name := fmt.Sprintf("ec2-test-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/simple-alb-ec2",
		Upgrade:      true,

		Vars: map[string]interface{}{
			"vpc_name": expectedName,
			"ec2_name": ec2Name,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

}
