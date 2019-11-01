import sys, os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lib"))

from splunklib.modularinput import *

class MyScript(Script):

    def get_scheme(self):
        # Returns scheme.

        scheme = scheme("API Data Reader")
        scheme.description = "Streams events from an API"

        scheme.use_external_validation = True
        scheme.use_single_instance = True

        

    def validate_input(self, validation_definition):
        # Validates input.

    def stream_events(self, inputs, ew):
        # Splunk Enterprise calls the modular input,
        # streams XML describing the inputs to stdin,
        # and waits for XML on stdout describing events.

if __name__ == "__main__":
    sys.exit(MyScript().run(sys.argv))