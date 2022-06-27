# Building an EAP 8 application image using EAP 8 S2I binary build

In this example we are making use of the EAP 8 S2I builder image to build an EAP 8 server + JAX-RS application docker image on Openshift.
In order to create an EAP 8 server containing our application, we are using the [EAP Maven Plugin](https://github.com/jbossas/eap-maven-plugin).

# Use-cases

* Test EAP 8 new features and/or bug fixes on Openshift.

# EAP 8 Maven plugin configuration

High level view of the WildFly Maven plugin configuration.

## Galleon feature-packs

* `org.jboss.eap:wildfly-ee-galleon-pack`
* `org.jboss.eap.cloud:eap-cloud-galleon-pack`

## Galleon layers

* `jaxrs-server`

## CLI scripts

WildFly CLI scripts executed at packaging time

* None

## Extra content

Extra content packaged inside the provisioned server

* None

# Openshift build and deployment

Technologies required to build and deploy this example

* NONE, image is built in Openshift.

# Pre-requisites

* You have a `Registry Service Account`. You can [create one](https://access.redhat.com/terms-based-registry/).

* You have downloaded the openshift secret file allowing to pull images in Openshift. For detailed instructions check the URL: https://access.redhat.com/terms-based-registry/#/token/<your user id>/openshift-secret`

* You are logged into an OpenShift cluster and have `oc` command in your path

* You have built EAP 8 and artifacts are present in your local maven cache

# Example steps

## Build the server

1. Build the application  and server

```
mvn clean package [-Dversion.eap=<your SNAPSHOT version>]
```

## Build the image on Openshift

1. Import the EAP 8 s2i Builder image in Openshift

Create the authentication token secret for your OpenShift project using the YAML file that you downloaded:

```
oc create -f 1234567_myserviceaccount-secret.yaml
```

Configure the secret for your OpenShift project using the following commands, 
replacing the secret name in the example with the name of your secret created in the previous step.

```
oc secrets link default 1234567-myserviceaccount-pull-secret --for=pull
oc secrets link builder 1234567-myserviceaccount-pull-secret --for=pull
```

Import the image

```
oc import-image jboss-eap-8-tech-preview/eap8-openjdk11-builder-openshift-rhel8:latest --from=registry.redhat.io/jboss-eap-8-tech-preview/eap8-openjdk11-builder-openshift-rhel8:latest --confirm
```

1. Create the binary build.

```
oc new-build --strategy source --binary --image-stream eap8-openjdk11-builder-openshift-rhel8 --name eap8-binary-build-app-build
```

2. Start a binary build from the full server that will output the application image.

```
oc start-build eap8-binary-build-app-build --from-dir target/server
```

2.1 [Alternative] Start a binary build from the deployment only that will provision the EAP8 server, deploy the deployment and output the application image.

```
oc start-build eap8-binary-build-app-build --from-file target/ROOT.war --env GALLEON_PROVISION_LAYERS=jaxrs-server \
--env GALLEON_PROVISION_FEATURE_PACKS="org.jboss.eap:wildfly-ee-galleon-pack,org.jboss.eap.cloud:eap-cloud-galleon-pack" \
--env GALLEON_PROVISION_CHANNELS="org.jboss.eap.channels:eap-8.0-beta"
```

3. Deploy the example application

```
oc new-app eap8-binary-build-app
oc expose svc/eap8-binary-build-app
```

4. Access the endpoint

```
curl https://$(oc get route eap8-binary-build-app --template='{{ .spec.host }}')/
```
