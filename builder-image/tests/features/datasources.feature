Feature: EAP configured for datasources

Scenario: Build image with server and datasource
    Given s2i build https://github.com/jboss-container-images/jboss-eap-8-openshift-image from test/test-app-postgres with env and true using eap8-beta-dev
    | variable                 | value           |
    | GALLEON_USE_LOCAL_FILE | true |
    | POSTGRESQL_DRIVER_VERSION | 42.2.19 |
    ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
    Then container log should contain WFLYSRV0025

  Scenario: Build image with server  and datasources
    Given s2i build https://github.com/jboss-container-images/jboss-eap-8-openshift-image from test/test-app-postgresql-oracle-legacy with env and true using eap8-beta-dev
    | variable                 | value           |
    | GALLEON_USE_LOCAL_FILE | true |
    | POSTGRESQL_DRIVER_VERSION | 42.2.19 |
    | ORACLE_DRIVER_VERSION | 19.3.0.0|
    ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
    Then container log should contain WFLYSRV0025

 Scenario: Build image with server  and datasources
    Given s2i build https://github.com/jboss-container-images/jboss-eap-8-openshift-image from test/test-app-postgresql-oracle with env and true using eap8-beta-dev
    | variable                 | value           |
    | POSTGRESQL_DRIVER_VERSION | 42.2.19 |
    | ORACLE_DRIVER_VERSION | 19.3.0.0|
    ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
    Then container log should contain WFLYSRV0025

  Scenario:  Test addition of datasource
     When container integ- is started with env
      | variable                     | value                                         |
      | DB_SERVICE_PREFIX_MAPPING    | TEST-postgresql=test                          |
      | TEST_POSTGRESQL_SERVICE_HOST | localhost                                     |
      | TEST_POSTGRESQL_SERVICE_PORT | 5432                                          |
      | test_DATABASE                | demo                                          |
      | test_JNDI                    | java:jboss/datasources/test-postgresql        |
      | test_JTA                     | false                                         |
      | test_NONXA                   | true                                          |
      | test_PASSWORD                | demo                                          |
      | test_URL                     | jdbc:postgresql://localhost:5432/postgresdb   |
      | test_USERNAME                | demo                                          |
    Then container log should contain WFLYSRV0025
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value test_postgresql-test on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value OracleDS on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value PostgreSQLDS on XPath //*[local-name()='datasource']/@pool-name
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |

  Scenario: Test dirver added during provisioning.
     When container integ- is started with env
      | variable                     | value                                                       |
      | ENV_FILES                    | /opt/server/standalone/configuration/datasources.env |
      | POSTGRESQL_ENABLED | false |
      | ORACLE_ENABLED            | false |
    Then container log should contain WFLYSRV0025
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value test-TEST on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value postgresql on XPath //*[local-name()='driver']/@name

  Scenario: Test external driver created during s2i.
     When container integ- is started with env
      | variable                     | value                                                       |
      | ENV_FILES                    | /opt/server/standalone/configuration/datasources.env |
      | POSTGRESQL_ENABLED | false |
      | ORACLE_ENABLED            | false |
      | DISABLE_BOOT_SCRIPT_INVOKER  | true |
    Then container log should contain Configuring the server using embedded server
    Then container log should contain WFLYSRV0025
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value test-TEST on XPath //*[local-name()='datasource']/@pool-name
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value postgresql on XPath //*[local-name()='driver']/@name