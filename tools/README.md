Build images: 
sh ./1-build-images.sh

Build images containing maven repository content:
sh ./2-build-images-from-maven-repo.sh /home/jdenise/Downloads/jboss-eap-8.0.0.Beta-redhat-0-20220601-maven-repository.zip

Run behave tests:
sh ./3-run-behave-tests.sh

Run extra tests:
sh ./4-run-extra-tests.sh

Do all in a single step:
sh ./build-images-and-run-all-tests.sh /home/jdenise/Downloads/jboss-eap-8.0.0.Beta-redhat-0-20220601-maven-repository.zip

Run a single behave feature file:
sh ./run-single-behave-test.sh <feature file>

# For very special cases.
Build an ultra custom image with custom cloud FP, custom eap maven plugin, custom WildFly maven plugin: 

sh ./build-custom-image.sh /home/jdenise/workspaces/eap-cloud-galleon-pack /home/jdenise/workspaces/eap-maven-plugin-doc/ \
/home/jdenise/Downloads/jboss-eap-8.0.0.Beta-redhat-99999-maven-repository.zip \
/home/jdenise/workspaces/wildfly-maven-plugin

docker run -it --rm --env=GALLEON_PROVISION_CHANNELS="org.jboss.eap.channels:eap-8.0-beta" --env=GALLEON_PROVISION_FEATURE_PACKS=org.jboss.eap:wildfly-ee-galleon-pack,org.jboss.eap.cloud:eap-cloud-galleon-pack \
--env=GALLEON_PROVISION_LAYERS=cloud-server \
jboss-eap-8-tech-preview/custom-eap8-openjdk11-builder:dev \
bash