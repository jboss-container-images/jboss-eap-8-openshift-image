@jboss-eap-8
@jboss-eap-8-tech-preview
Feature: EAP extensions tests

  Scenario: Build server image
    Given s2i build https://github.com/jboss-container-images/jboss-eap-8-openshift-image from test/test-app-advanced-extensions with env and True using eap82-dev
    | variable                             | value         |
    ### PLACEHOLDER FOR CLOUD CUSTOM TESTING ###
    Then exactly 2 times container log should contain WFLYSRV0025:

  Scenario: Test preconfigure.sh
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_PRE_ADD_PROPERTY      | foo           |
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value foo on XPath //*[local-name()='property' and @name="foo"]/@value

   Scenario: Test preconfigure.sh fallback CLI
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_PRE_ADD_PROPERTY      | foo           |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then container log should contain WFLYSRV0025
    Then container log should contain Configuring the server using embedded server
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value foo on XPath //*[local-name()='property' and @name="foo"]/@value

   Scenario: Test preconfigure.sh calls CLI
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_PRE_START_CLI_COMMAND | /system-property=foo:add(value=bar)           |
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value bar on XPath //*[local-name()='property' and @name="foo"]/@value

   Scenario: Test preconfigure.sh calls CLI
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_PRE_START_CLI_COMMAND | /system-property=foo:add(value=bar)           |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then container log should contain WFLYSRV0025
    Then container log should contain Configuring the server using embedded server
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value bar on XPath //*[local-name()='property' and @name="foo"]/@value

  Scenario: Test preconfigure.sh fails in bash
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_PRE_FAIL      | TEST_ERROR_MESSAGE |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log  should not contain WFLYSRV0025
    Then file /tmp/boot.log  should contain TEST_ERROR_MESSAGE
    And file /tmp/boot.log  should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")

  # This test is too fragile when we are disabling SCRIPT_INVOKER (that is unsupported).
  # Fragility comes from the fact that no java process is started in the test framework look for existing process. 
  @ignore
  Scenario: Test preconfigure.sh fails in bash
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_PRE_FAIL      | TEST_ERROR_MESSAGE |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log should not contain WFLYSRV0025
    Then file /tmp/boot.log should contain TEST_ERROR_MESSAGE
    And file /tmp/boot.log should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")

  Scenario: Test preconfigure.sh fails in CLI script
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_PRE_CLI_FAIL  | rubbish       |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log should contain WFLYSRV0025
    Then file /tmp/boot.log should contain rubbish
    And file /tmp/boot.log should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And file /tmp/boot.log should contain Error, server failed to configure. Can't proceed with custom extensions script

  # This test is too fragile when we are disabling SCRIPT_INVOKER (that is unsupported).
  # Fragility comes from the fact that no java process is started in the test framework look for existing process. 
  @ignore 
  Scenario: Test preconfigure.sh fails in CLI script
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_PRE_CLI_FAIL  | rubbish       |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log should contain Configuring the server using embedded server
    Then file /tmp/boot.log should contain WFLYSRV0025
    Then file /tmp/boot.log should contain rubbish
    And container log should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")

  Scenario: Test preconfigure.sh restart
    When container integ- is started with env
      | variable                     | value         |
      | TEST_EXTENSION_PRE_CLI_RESTART  | true       |
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And container log should contain Server has been shutdown and must be restarted.
    And container log should contain Restarting the server
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |

  Scenario: Test postconfigure.sh
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_POST_ADD_PROPERTY      | foo           |
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value foo on XPath //*[local-name()='property' and @name="foo"]/@value

  Scenario: Test postconfigure.sh
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_POST_ADD_PROPERTY      | foo           |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then container log should contain Configuring the server using embedded server
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value foo on XPath //*[local-name()='property' and @name="foo"]/@value

  Scenario: Test postconfigure.sh calls CLI
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_POST_START_CLI_COMMAND | /system-property=foo:add(value=bar)           |
      | TEST_EXTENSION_POST_START_EMBEDDED_CLI_COMMAND | /system-property=foo2:add(value=bar2)           |
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value bar on XPath //*[local-name()='property' and @name="foo"]/@value
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value bar2 on XPath //*[local-name()='property' and @name="foo2"]/@value

  Scenario: Test postconfigure.sh calls CLI
    When container integ- is started with env
      | variable                             | value         |
      | TEST_EXTENSION_POST_START_EMBEDDED_CLI_COMMAND | /system-property=foo2:add(value=bar2)           |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then container log should contain Configuring the server using embedded server
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |
    Then XML file /opt/server/standalone/configuration/standalone.xml should contain value bar2 on XPath //*[local-name()='property' and @name="foo2"]/@value

  Scenario: Test postconfigure.sh fails in bash
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_POST_FAIL      | TEST_ERROR_MESSAGE |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log should contain WFLYSRV0025
    And file /tmp/boot.log should contain Shutdown server
    And file /tmp/boot.log should contain Shutting down in response to management operation 'shutdown'
    And file /tmp/boot.log should contain TEST_ERROR_MESSAGE
    And file /tmp/boot.log should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")

  # This test is too fragile when we are disabling SCRIPT_INVOKER (that is unsupported).
  # Fragility comes from the fact that no java process is started in the test framework look for existing process. 
  @ignore 
  Scenario: Test postconfigure.sh fails in bash
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_POST_FAIL      | TEST_ERROR_MESSAGE |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log should contain Configuring the server using embedded server
    Then file /tmp/boot.log should not contain WFLYSRV0025
    And file /tmp/boot.log should contain TEST_ERROR_MESSAGE
    And file /tmp/boot.log should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")

 Scenario: Test postconfigure.sh fails in CLI script
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_POST_CLI_FAIL  | rubbish       |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log should contain WFLYSRV0025
    And file /tmp/boot.log should contain Shutdown server
    And file /tmp/boot.log should contain rubbish
    And file /tmp/boot.log should contain Shutting down in response to management operation 'shutdown'
    And file /tmp/boot.log should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")

  Scenario: Test postconfigure.sh fails in CLI script
    When container integ- is started with command bash
      | variable                     | value         |
      | TEST_EXTENSION_POST_CLI_FAIL  | rubbish       |
      | DISABLE_BOOT_SCRIPT_INVOKER | true |
    Then run sh -c '/opt/jboss/container/wildfly/run/run  > /tmp/boot.log 2>&1' in container and detach
    Then file /tmp/boot.log should contain Configuring the server using embedded server
    And file /tmp/boot.log should contain rubbish
    And file /tmp/boot.log should not contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")

  Scenario: Test postconfigure.sh restart
    When container integ- is started with env
      | variable                     | value         |
      | TEST_EXTENSION_POST_CLI_RESTART  | true       |
    Then container log should contain WFLYSRV0025
    And container log should contain WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
    And container log should contain Server has been shutdown and must be restarted.
    And container log should contain Restarting the server
    And check that page is served
      | property | value |
      | path     | /     |
      | port     | 8080  |