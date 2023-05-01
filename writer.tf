# Configures the Google Cloud provider with the project ID and the region to use, which is europe-west2 for London.
provider "google" {
  project = "dsuite-dnd-ds-test"
  region  = "europe-west2"
}

# Creates a VPC network with the name dnd-ds-vpc and disables the auto-creation of subnetworks.
resource "google_compute_network" "dnd-ds-vpc" {
  project                 = "dsuite-dnd-ds-test"
  name                    = "dnd-ds-vpc"
  auto_create_subnetworks = false
}

# Creates a subnet with the name dnd-ds-subnet and the IP range 10.0.0.0/16 in the europe-west2 region.
# It also references the VPC network ID as the network attribute.

# The IP range for the subnet is arbitrary and can be changed according to your needs. However,
# it should be a valid private IP range that does not overlap with any other subnets in the same VPC network or
# any peered networks. The IP range also determines the number of available IP addresses for the subnet.
# For example, the IP range 10.0.0.0/16 has 65,536 possible IP addresses, while the IP range 10.8.0.0/28 has
# only 16 possible IP addresses. You should choose an IP range that is large enough to accommodate your
# expected traffic and growth, but not too large to waste IP addresses or cause conflicts with other networks.
resource "google_compute_subnetwork" "dnd-ds-subnet" {
  project       = "dsuite-dnd-ds-test"
  name          = "dnd-ds-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "europe-west2"
  network       = google_compute_network.dnd-ds-vpc.id
}

# Creates a Pub/Sub topic with the name dnd-ds-character.
resource "google_pubsub_topic" "dnd-ds-character" {
  project = "dsuite-dnd-ds-test"
  name    = "dnd-ds-character"
}

# TODO: This is not connected to VPC? It should be.

# Creates a Cloud Run service with the name dnd-ds-cloudrun-writer in the europe-west2 region. It uses the template
# block to specify the container image to run, which is assumed to be a Java 20 Spring Boot application
# that is already pushed to Google Container Registry. It also sets an environment variable dnd.ds.character
# to point to the Pub/Sub topic ID. It uses the traffic block to route all traffic to the latest revision of
# the service. It also sets some annotations to enable autoscaling and launch stage. It also sets the service
# account name to use the service account that will be created later.

# Cloud Run automatically sets some environment variables for each service, such as PORT, K_SERVICE, K_REVISION, etc...
# The Spring Boot application can access environment variables like PORT even if it is not present in the
# application.properties file. The application.properties file is used to specify the configuration properties
# for the Spring Boot application, but it is not the only source of externalized configuration.
# The environment variables are another source of externalized configuration that can override or complement
# the properties in the application.properties file. The Spring Boot application can access any environment
# variable that is set for the Cloud Run service, regardless of whether it is defined in the application.properties
# file or not. However, if there is a conflict between an environment variable and a property
# in the application.properties file, the environment variable will take precedence.
resource "google_cloud_run_service" "dnd-ds-cloudrun-writer" {
  project                    = "dsuite-dnd-ds-test"
  name                       = "dnd-ds-cloudrun-writer"
  location                   = "europe-west2"
  autogenerate_revision_name = true
  template {
    spec {
      container_concurrency = 1
      service_account_name  = google_service_account.dnd-ds-writer-service-account.email
      containers {
        image = "gcr.io/dsuite-dnd-ds-test/writer-image"
        env {
          name  = "dnd.ds.character"
          value = google_pubsub_topic.dnd-ds-character.id
        }
        resources {
          limits = {
            cpu    = "1"
            memory = "256Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# TODO: Is this even needed? Do I want to map a domain to a url? I don't think so.

# Creates a Cloud Run domain mapping with the name d-suite.dev. It maps the domain name to the Cloud Run service
# route name. It also sets the namespace to match the service namespace.
#resource "google_cloud_run_domain_mapping" "dnd-ds-domain-mapping" {
#  location = google_cloud_run_service.dnd-ds-cloudrun-writer.location
#  name     = "d-suite.dev"
#
#  metadata {
#    namespace = google_cloud_run_service.dnd-ds-cloudrun-writer.metadata[0].namespace
#  }
#
#  spec {
#    route_name = google_cloud_run_service.dnd-ds-cloudrun-writer.name
#  }
#}

# Creates a service account for the Cloud Run service.
resource "google_service_account" "dnd-ds-writer-service-account" {
  project      = "dsuite-dnd-ds-test"
  account_id   = "dnd-ds-writer-service-account"
  display_name = "dnd-ds-writer-service-account"
}

# Grants the service account the Cloud Run Invoker role, which allows it to invoke Cloud Run services.
resource "google_project_iam_member" "invoker" {
  project = "dsuite-dnd-ds-test"
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.dnd-ds-writer-service-account.email}"
}

# Grants the service account the Pub/Sub Publisher role, which allows it to publish messages to Pub/Sub topics.
resource "google_project_iam_member" "publisher" {
  project = "dsuite-dnd-ds-test"
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.dnd-ds-writer-service-account.email}"
}

# Creates a Serverless VPC Access connector with the name dnd-ds-access-connector and the IP range 10.8.0.0/28
# in the europe-west2 region. It also references the VPC network ID as the network attribute.
# This connector allows the Cloud Run service to access resources in the VPC network, such as databases or other services.
resource "google_vpc_access_connector" "dnd-ds-access-connector" {
  project       = "dsuite-dnd-ds-test"
  name          = "dnd-ds-access-connector"
  region        = "europe-west2"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.dnd-ds-vpc.id
}

# TODO: The provider hashicorp/google does not support resource type "google_cloud_run_service_vpc_access_connector".
#  However, you can still configure the VPC Access connector for your Cloud Run service using other means outside of Terraform.
#  You can use the GCP Console or the gcloud command-line tool to create and configure the connector.

# Attaches the connector to the Cloud Run service by referencing their names and locations.
# This enables the Cloud Run service to use the connector for VPC access.
#resource "google_cloud_run_service_vpc_access_connector" "dnd-ds-cloudrun-writer-access-connector" {
#  service = google_cloud_run_service.dnd-ds-cloudrun-writer.name
#  location = google_cloud_run_service.dnd-ds-cloudrun-writer.location
#  vpc_connector = google_vpc_access_connector.dnd-ds-access-connector.id
#}