data "aws_ssm_parameter" "adminpass" {
  name = "adminpass"
}

resource "aws_directory_service_directory" "numerix" {
  name     = "numerix-md.com"
  password = data.aws_ssm_parameter.adminpass.value
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.microsoft-ad.id
    subnet_ids = [for k, v in aws_subnet.private-microsoft-ad : v.id]
  }
  alias = "numerix"
  enable_sso = true

  tags = {
    Project = "demo-numerix"
  }
}
