
provider "vault" {
  address = "http://127.0.0.1:8200"
  skip_tls_verify = true
  token = "education"
}

data "vault_generic_secret" "vault_example" {
  path = "secret/example"
}

resource "vault_generic_secret" "example2" {
  path = "secret/example2"

  data_json = var.new_secret
}
