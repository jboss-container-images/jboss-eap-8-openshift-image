#IGNORE_TEST_RUN
# Can't be run currently with current keycloak: org.jboss.modules.ModuleNotFoundException: org.picketbox
@jboss-eap-8-tech-preview
Feature: Keycloak legacy tests

   Scenario: deploys the keycloak example, provision the default config. The app project is expected to install the keycloak adapters inside the server.
     Given XML namespaces
       | prefix | url                          |
       | ns     | urn:jboss:domain:keycloak:1.2 |
     Given s2i build https://github.com/jboss-container-images/jboss-eap-8-openshift-image from test/test-app-keycloak-legacy using eap8-beta-dev
       | variable                   | value                                            |
       | ARTIFACT_DIR               | app-profile-jee/target,app-profile-jee-saml/target |
       | SSO_USE_LEGACY  | true |
       | SSO_REALM         | demo    |
       | SSO_URL           | http://localhost:8080/auth    |
       | GALLEON_PROVISION_CHANNELS|org.jboss.eap.channels:eap-8.0 |
       | GALLEON_PROVISION_FEATURE_PACKS|org.jboss.eap:wildfly-ee-galleon-pack,org.jboss.eap.cloud:eap-cloud-galleon-pack |
       | GALLEON_PROVISION_LAYERS|cloud-default-config|
    Then container log should contain Existing other application-security-domain is extended with support for keycloak
    Then container log should contain WFLYSRV0025
    Then container log should contain WFLYSRV0010: Deployed "app-profile-jee.war"
    Then container log should contain WFLYSRV0010: Deployed "app-profile-jee-saml.war"
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value demo on XPath //*[local-name()='realm']/@name
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value app-profile-jee.war on XPath //*[local-name()='secure-deployment']/@name
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value false on XPath //*[local-name()='secure-deployment'][@name="app-profile-jee.war"]/*[local-name()='enable-cors']
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value http://localhost:8080/auth on XPath //*[local-name()='secure-deployment'][@name="app-profile-jee.war"]/*[local-name()='auth-server-url']
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value app-profile-jee-saml.war on XPath //*[local-name()='secure-deployment']/@name
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value app-profile-jee-saml on XPath //*[local-name()='secure-deployment'][@name="app-profile-jee-saml.war"]/*[local-name()='SP']/@entityID
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value EXTERNAL on XPath //*[local-name()='secure-deployment'][@name="app-profile-jee-saml.war"]/*[local-name()='SP']/@sslPolicy
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value true on XPath //*[local-name()='secure-deployment'][@name="app-profile-jee-saml.war"]/*[local-name()='SP']/*[local-name()='Keys']/*[local-name()='Key']/@signing 
    And XML file /opt/server/standalone/configuration/standalone.xml should contain value idp on XPath //*[local-name()='secure-deployment'][@name="app-profile-jee-saml.war"]/*[local-name()='SP']/*[local-name()='IDP']/@entityID 