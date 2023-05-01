# Nic - Writer

### Technologies

##### Terraform

###### Setup

1. Initialize the Working Directory: Navigate to the directory containing your configuration files and run the
terraform init command. This will initialize the working directory and download the necessary provider plugins.

2. Review and Apply the Changes: Use the terraform plan command to review the changes that will be made to your
infrastructure. If the plan looks good, use the terraform apply command to apply the changes and create or 
update the resources.

3. When you are done, you can run terraform destroy to destroy the resources created by Terraform.

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

To push your Maven Java 20 Spring Boot application to Google Container Registry, you can use the Jib Maven plugin, 
which simplifies the process of building and pushing container images without a Dockerfile or a Docker installation. 
You need to do the following steps:

- Add the Jib Maven plugin to your pom.xml file and configure the target image name. For example:
```
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>jib-maven-plugin</artifactId>
    <version>3.1.1</version>
    <configuration>
        <to>
            <image>gcr.io/your-project-id/your-image-name</image>
        </to>
    </configuration>
</plugin>
```

- Replace your-project-id with your Google Cloud project ID and your-image-name with your desired image name.

- Authenticate to Google Container Registry using the Google Cloud CLI as a Docker credential helper. You need 
to install the Google Cloud CLI and run the following command:
```
gcloud auth configure-docker
```

- Build and push the image to Google Container Registry using the Jib Maven plugin. You can run the following command:
```
mvn compile jib:build
```

- This will compile your application, create a container image, and push it to Google Container Registry. 
You can verify the success by viewing your container image in your Container Registry console.

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

