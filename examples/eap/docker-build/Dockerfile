ARG runtime_image=registry-proxy.engineering.redhat.com/rh-osbs/jboss-eap-8-tech-preview-eap8-openjdk11-runtime-openshift-rhel8:jb-eap-8.0-rhel-8-containers-candidate-24846-20220614093802
FROM ${runtime_image}
COPY --chown=jboss:root target/server $JBOSS_HOME
RUN chmod -R ug+rwX $JBOSS_HOME
