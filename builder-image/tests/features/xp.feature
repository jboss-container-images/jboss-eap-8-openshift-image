@xp5
@jboss-eap-8
Feature: Openshift XP tests

  Scenario: Check that the legacy default config provisioned using galleon plugin works fine
   Given s2i build https://github.com/jboss-container-images/jboss-eap-8-openshift-image from test/xp/test-app-default-config with env and True using eap8-dev
   | variable                 | value           |
   | S2I_SERVER_DIR | server |
   ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
   Then container log should contain Running jboss-eap-8/
   Then exactly 2 times container log should contain WFLYSRV0025:

  Scenario: Micro-profile config configuration, galleon s2i
    When container integ- is started with env
       | variable                                | value           |
       | MICROPROFILE_CONFIG_DIR                 | /home/jboss     |
       | MICROPROFILE_CONFIG_DIR_ORDINAL         | 88              |
       ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value /home/jboss on XPath //*[local-name()='config-source' and @name='config-map']/*[local-name()='dir']/@path
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value 88 on XPath //*[local-name()='config-source' and @name='config-map']/@ordinal

Scenario: Check that trimmed server provisioned using galleon plugin works fine
   Given s2i build https://github.com/jboss-container-images/jboss-eap-8-openshift-image from test/xp/test-app with env and True using eap8-dev
   | variable                 | value           |
   ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
   Then container log should contain Running jboss-eap-8/
   Then exactly 2 times container log should contain WFLYSRV0025:

  Scenario: Micro-profile config configuration, galleon s2i
    When container integ- is started with env
       | variable                                | value           |
       | MICROPROFILE_CONFIG_DIR                 | /home/jboss     |
       | MICROPROFILE_CONFIG_DIR_ORDINAL         | 99              |
       ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value /home/jboss on XPath //*[local-name()='config-source' and @name='config-map']/*[local-name()='dir']/@path
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value 99 on XPath //*[local-name()='config-source' and @name='config-map']/@ordinal

Scenario: Check with env based legacy configuration
   Given s2i build http://github.com/openshift/openshift-jee-sample from . using master
   | variable                 | value           |
   | GALLEON_PROVISION_LAYERS | cloud-server, microprofile-config |
   | GALLEON_PROVISION_FEATURE_PACKS | org.jboss.eap.xp:wildfly-galleon-pack,org.jboss.eap.xp.cloud:eap-xp-cloud-galleon-pack |
   | GALLEON_PROVISION_CHANNELS | org.jboss.eap.channels:eap-8.0,org.jboss.eap.channels:eap-xp-5.0 |  
   Then container log should contain Running jboss-eap-8/
   Then exactly 2 times container log should contain WFLYSRV0025:

Scenario: Micro-profile config configuration, galleon s2i
    When container integ- is started with env
       | variable                                | value           |
       | MICROPROFILE_CONFIG_DIR                 | /home/jboss     |
       | MICROPROFILE_CONFIG_DIR_ORDINAL         | 99              |
       ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value /home/jboss on XPath //*[local-name()='config-source' and @name='config-map']/*[local-name()='dir']/@path
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value 99 on XPath //*[local-name()='config-source' and @name='config-map']/@ordinal

