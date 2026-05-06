
Build with podman:

* JDK21: `cekit --redhat build podman`
* JDK25: `cekit --redhat build --overrides image-jdk25-overrides.yaml podman`

Build with OSBS:

* JDK21: `cekit --redhat build --overrides rh-jdk21-overrides.yaml osbs`
* JDK25: `cekit --redhat build --overrides image-jdk25-overrides.yaml --overrides rh-jdk25-overrides.yaml osbs`