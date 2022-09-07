# Building an EAP 8 application image using EAP 8 S2I source build

In this example we are making use of the EAP 8 S2I builder and runtime images to build an EAP 8 server + JAX-RS application docker image on Openshift.
In order to create an EAP 8 server containing our application, we are using the [EAP Maven Plugin](https://github.com/jbossas/eap-maven-plugin).

# Use-cases

* User typical S2I workflow. Start from a github source repository, use latest released EAP 8 artifacts and images.

# EAP 8 Maven plugin configuration

High level view of the EAP Maven plugin configuration.

## Galleon feature-packs

* `org.jboss.eap:wildfly-ee-galleon-pack`
* `org.jboss.eap.cloud:eap-cloud-galleon-pack`

NB, the versions of the feature-packs are retrieved from the latest EAP8 channel: `org.jboss.eap.channels:eap-8.0-beta`

## Galleon layers

* `jaxrs-server`

## CLI scripts

JBoss EAP CLI scripts executed at packaging time

* None

## Extra content

Extra content packaged inside the provisioned server

* None

# Openshift build and deployment

Technologies required to build and deploy this example

* TO BE UPDATED WITH EAP/XP helm charts: Helm chart for WildFly `wildfly/wildfly`. Minimal version `2.0.0`.

# Pre-requisites

* You have a `Registry Service Account`. You can [create one](https://access.redhat.com/terms-based-registry/).

* [Not needed for OpenShift Sandbox] You have downloaded the Openshift secret file allowing to pull images in openshift. For detailed instructions check the URL: https://access.redhat.com/terms-based-registry/#/token/<your user id>/openshift-secret`

* You are logged into an OpenShift cluster and have `oc` command in your path.

* You have installed Helm. Please refer to [Installing Helm page](https://helm.sh/docs/intro/install/) to install Helm in your environment

* You have installed the repository for the Helm charts for WildFly

 ```
helm repo add wildfly https://docs.wildfly.org/wildfly-charts/
```

# Example steps

1. Setup to pull EAP 8 s2i builder and runtime images in Openshift [only required for on-premise installation of OpenShift, not needed for OpenShift Sandbox]

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

2. Deploy the example application using WildFly Helm charts

```
helm install eap8-source-build-app -f helm.yaml wildfly/wildfly
```

3. Access the endpoint

```
curl https://$(oc get route eap8-source-build-app --template='{{ .spec.host }}')/
```
