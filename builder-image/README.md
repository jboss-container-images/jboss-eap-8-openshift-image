
Build with docker:

* JDK11: `cekit --redhat build docker`
* JDK17: `cekit --redhat build --overrides image-jdk17-overrides.yaml docker`

Build with OSBS:

* JDK11: `cekit --redhat build --overrides rh-jdk11-overrides.yaml osbs`
* JDK17: `cekit --redhat build --overrides image-jdk17-overrides.yaml --overrides rh-jdk17-overrides.yaml osbs`