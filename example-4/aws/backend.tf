# We use terraform cloud as the backend

terraform {
  cloud {
    organization = "aptezzo-microservices"

    workspaces {
      name = "bootstrapping-microservices-chapter-7"
    }
  }
}
