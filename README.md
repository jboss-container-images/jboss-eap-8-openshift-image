# jboss-eap-8-openshift-image
 OpenShift container images for Red Hat JBoss Enterprise Application Platform 8

This project defines Images allowing you to build and deploy EAP 8 applications on the cloud.

EAP 8 S2I (Source-To-Image) builder images:

* `jboss-eap-8-tech-preview/eap8-openjdk11-builder-openshift-rhel8`

* `jboss-eap-8-tech-preview/eap8-openjdk17-builder-openshift-rhel8`

EAP 8 runtime images:

* `jboss-eap-8-tech-preview/eap8-openjdk11-runtime-openshift-rhel8`

* `jboss-eap-8-tech-preview/eap8-openjdk17-runtime-openshift-rhel8`

----
**NOTE**

When using both a builder and a runtime images, make sure to use images that share the same JDK version.
----

# Examples

These examples cover the 3 typical ways to build/deploy applications for Openshift using EAP 8 Openshift images.

EAP 8 developers use cases:

 * [Docker local build](examples/eap/docker-build), required tooling: `jdk`, `maven`, `docker`, `oc`. Best suited when testing EAP 8 new features/bug fixes.

 * [S2I (Source-To-Image) binary build](examples/eap/s2i-binary-build), required tooling: `jdk`, `maven`, `oc`. Best suited when testing EAP 8 new features/bug fixes.

EAP 8 users use cases:

 * [S2I source build](examples/eap/s2i-source-build), required tooling: `oc`. Best suited when testing an application deployed to latest EAP 8 server with sources located in a git repository.
 
 * [S2I (Source-To-Image) binary build](examples/eap/s2i-binary-build), deployment only binary build, required tooling: `jdk`, `maven`, `oc`. Best suited when testing an application deployed to latest EAP 8 server with deployment built locally.

# Relationship with EAP 7.x images

As opposed to the EAP 7.x S2I (Source-To-Image) builder image that contains an EAP server, the new builder image 
is a generic builder allowing to build image for any EAP 8 releases.

# EAP 8 - S2I builder image

The S2I builder image contains all you need to execute a Maven build of your project during an S2I build phase on OpenShift.

## S2I build workflow

The builder image requires that, during the Maven build, an EAP 8 server containing the deployment is being provisioned (by default in `<application project>/target/server` directory). This provisioned server 
is installed by the image in `/opt/server`. Making the generated application image runnable.

In order to provision a server during the build phase you must integrate (generally in a profile named `openshift` profile) an execution of the  [EAP Maven plugin](https://github.com/jbossas/eap-maven-plugin/) `package` goal.

## Using the S2I builder image

The more efficient way to use the EAP 8 S2I builder image to construct an EAP application image is by using [EAP Helm charts](https://github.com/jbossas/eap-charts).
EAP Helm Charts  are automating the build (on OpenShift) and deployment of your application by the mean of a simple yaml file.

## Galleon feature-pack for EAP 8 on the Cloud

The [EAP cloud feature-pack](https://github.com/jbossas/eap-cloud-galleon-pack) contains all the cloud specifics that were contained in the EAP 7.x image.
This feature-pack has to be provisioned along with the EAP 8 `org.jboss.eap:wildfly-ee-galleon-pack` feature-pack. 

For more information on the EAP cloud feature-pack features, check [this documentation](https://github.com/jbossas/eap-cloud-galleon-pack/blob/main/README.md).

## Backward compatible S2I workflow

In case you want to keep your existing project that used to work with the legacy EAP 7.x S2i builder image, you can use a set of environment variables 
to initiate a server provisioning prior to execute the Maven build of your application:

* `GALLEON_PROVISION_FEATURE_PACKS`: Comma separated lists of Galleon feature-packs, for example: 
`GALLEON_PROVISION_FEATURE_PACKS=org.jboss.eap:wildfly-ee-galleon-pack:8.0.0.GA-redhat-0001,org.jboss.eap.cloud:eap-cloud-galleon-pack:8.0.0.Final-redhat-00001` 

* `GALLEON_PROVISION_LAYERS`: Comma separated lists of Galleon layers, for example: `GALLEON_PROVISION_LAYERS=cloud-server,postgresql-datasource`

NB: This support is deprecated. You are strongly advised to update your project to integrate the [EAP Maven plugin](https://github.com/jbossas/eap-maven-plugin/) in your Maven project.

# EAP 8 - runtime image

The runtime image contains all you need to run an EAP 8 Server and application.

## Using the EAP 8 runtime image

This image is to be used when building a container image to run an EAP 8 server and application.

When building an application using [EAP Helm charts](https://github.com/jbossas/eap-charts), the generated image 
that contains the server and application is based on the EAP 8 runtime image.

# Image runtime API

When running an EAP 8 server inside the EAP 8 runtime or S2I builder image, you can use [these environment variables](https://github.com/jboss-container-images/openjdk/blob/develop/modules/jvm/api/module.yaml) to configure the Java VM.
The EAP 8 runtime and S2I builder images are exposing a set of [environment variables](https://github.com/wildfly/wildfly-cekit-modules/blob/main/jboss/container/wildfly/run/api/module.yaml) to fine tune the server execution.
