# Writer

## Developer Notes

### Technologies

##### Terraform

###### General Knowledge - Does Terraform create duplicate resources from other terraform files?

If a resource is already created, Terraform will not create it again.

For example, if both Terraform files define the same Cloud Storage bucket with the same name, 
Terraform will detect that the bucket already exists and will not create a duplicate bucket. However, 
if the two files define different properties for the bucket (e.g. different access control settings), 
Terraform may try to update the bucket with the new settings, which could potentially cause conflicts 
or errors if the settings are incompatible.

In some cases, duplicate resources may be created unintentionally if there are conflicting dependencies or if the
resources are managed in different states. For example, if one Terraform file creates a Compute Engine instance
and another file creates a firewall rule for that instance, but the firewall rule is defined before the instance
is created, Terraform may create a duplicate firewall rule before the instance is created.

###### Setup

1. Initialize the Working Directory: Navigate to the directory containing your configuration files and run the
`terraform init` command. This will initialize the working directory and download the necessary provider plugins.

2. Review and Apply the Changes: Use the `terraform plan` command to review the changes that will be made to your
infrastructure. If the plan looks good, use the `terraform apply` command to apply the changes and create or 
update the resources.

3. When you are done, you can run `terraform destroy` to destroy the resources created by Terraform.

##### GCP

###### If not using Terraform - Creating project and Pub/Sub topic.

1. [Set up your Google Cloud project ID and credentials as described in 1](https://cloud.google.com/pubsub/docs/spring).
2. Create a Pub/Sub topic and subscription in your Google Cloud project using the console or the 
gcloud command-line tool. For example:

```
gcloud pubsub topics create my-topic
gcloud pubsub subscriptions create my-subscription --topic=my-topic
```

###### Pushing container to Google Container Registry.

To push your Maven Java 20 Spring Boot application to Google Container Registry, You can create a Dockerfile that 
specifies the instructions for building your image, such as the base image, application files, and dependencies. 
Then, you can use the Docker CLI to build the image and push it to Google Container Registry.

1. Authenticate with Google Cloud SDK: Run `gcloud auth login` to authenticate with Google Cloud SDK.
2. Build the image: Run `docker build -t writer-image:latest .`
3. Tag the Docker image: Run `docker tag writer-image:latest gcr.io/dsuite-dnd-ds-test/writer-image:latest` to tag the local Docker image with the GCR image name.
   - Replace `latest` with a tag to identify the version of the Docker image you are pushing. For example, you can use the Docker image version or a custom tag.
4. Push the Docker image to GCR: Run `docker push gcr.io/dsuite-dnd-ds-test/writer-image:latest` to push the Docker image to GCR.
   - Replace `latest` with the tag you used in the previous step.

###### How to listen to a GCP Pub/Sub Topic when Spring Boot Application boots.

1. Create a Spring Boot application with dependency: spring-cloud-gcp-starter-pubsub.

2. Subscribe to the topic when the application is run by using an @PostConstruct annotation on a method that calls 
the pubSubTemplate.subscribe() method. This way, the subscription will be created when the application context is 
initialized and you don’t need to call a REST endpoint to start listening to the topic.

### Spring Boot - Reference Documentation
For further reference, please consider the following sections:

* [Official Apache Maven documentation](https://maven.apache.org/guides/index.html)
* [Spring Boot Maven Plugin Reference Guide](https://docs.spring.io/spring-boot/docs/3.0.6/maven-plugin/reference/html/)
* [Create an OCI image](https://docs.spring.io/spring-boot/docs/3.0.6/maven-plugin/reference/html/#build-image)
* [Spring Boot DevTools](https://docs.spring.io/spring-boot/docs/3.0.6/reference/htmlsingle/#using.devtools)

