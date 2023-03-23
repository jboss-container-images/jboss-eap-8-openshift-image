# jboss-eap-8-openshift-image testing

Tests are provided for images defined in this repository.

Tests are based on the [Behave](https://pypi.org/project/behave/) testing framework which
permits defining, executing and reporting on tests implemented using a behaviour driven development (BDD) paradigm. 
Tests are organized into features, features into scenarios, and each scenario described in terms of @given, 
@when and @then clauses: given an image in a certain state, when an action or event occurs, then verify that a specific
assertion should hold. By convention, tests are located in the tests sub-directory of the builder-image and runtime-image 
directories.

The tests can be used to start a container image with a set of pre-defined parameters, interact with the image instance 
and then test assertions on the effect of the action on the container image.

These tests are broadly aimed at validating the configurational integrity of the image; in other words,
to validate that the configuration of the built image conforms to the specification of the image as described
in the image definition file. Validations include, but are not limited to, checking that image configuration files 
have been correctly updated for execution the cloud, or that expected logging messages appear in the log files of
the image instance.

