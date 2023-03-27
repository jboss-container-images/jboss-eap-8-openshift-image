ARG runtime_image=registry-proxy.engineering.redhat.com/rh-osbs/jboss-eap-8-eap8-openjdk11-runtime-openshift-rhel8:latest
FROM ${runtime_image}
COPY --chown=jboss:root target/server $JBOSS_HOME
RUN chmod -R ug+rwX $JBOSS_HOME
