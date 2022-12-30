# Require the KerbalDyn module
require 'kerbaldyn'

# Connect to the KSP game using the KerbalDyn module
ksp = KerbalDyn::KSP.new

# Launch the spacecraft from the launchpad
ksp.launch(:rocket)

# Wait for the spacecraft to reach the desired altitude
while ksp.altitude < 100000
  sleep(1)
end

# Set the spacecraft's heading to prograde (towards the direction of travel)
ksp.set_heading(:prograde)

# Burn the spacecraft's engines to enter orbit
ksp.activate_engine

# Wait for the spacecraft to reach orbit
while ksp.speed < 7500
  sleep(1)
end

# Turn off the spacecraft's engines
ksp.deactivate_engine

# Disconnect from the KSP game
ksp.disconnect
