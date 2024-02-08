resource "aws_directory_service_directory" "numerix" {
  name     = "numerix-md.com"
  password = "adminpass"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.microsoft-ad.id
    subnet_ids = [for k, v in aws_subnet.private-microsoft-ad : v.id]
  }

  tags = {
    Project = "demo-numerix"
  }
}
