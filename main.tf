provider "aws" {
  access_key = "AKIAYJKGBQNLGLFXNHSR"
  secret_key = "BXQe9dexMWsGOFncn4DR7k16/cjqmc3XOQkt498W"
  region     = "us-east-2"
}


resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
