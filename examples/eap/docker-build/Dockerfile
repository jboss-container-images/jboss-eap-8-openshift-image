ARG runtime_image=registry.redhat.io/jboss-eap-8/eap81-openjdk17-builder-openshift-rhel9:latest
FROM ${runtime_image}
COPY --chown=jboss:root target/server $JBOSS_HOME
RUN chmod -R ug+rwX $JBOSS_HOME
