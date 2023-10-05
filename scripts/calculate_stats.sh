#!/bin/bash
# This script will perform some rudimentary analysis of the number of breaking updates found
# and the status of reproduction.

function get_fraction_as_percentage() {
  fraction=$(bc -l <<< "($1 * 100) / ($2 * 100) * 100")
  LC_NUMERIC=en_US.UTF-8 printf "%0.2f%%" "$fraction"
}

# Calculate numbers concerning the reproduction process.
num_compilation_failure=$(grep -ro "\"COMPILATION_FAILURE\"" data/benchmark | wc -l)
num_test_failure=$(grep -ro "\"TEST_FAILURE\"" data/benchmark | wc -l)
num_dependency_resolution_failure=$(grep -ro "\"DEPENDENCY_RESOLUTION_FAILURE\"" data/benchmark | wc -l)
num_enforcer_failure=$(grep -ro "\"ENFORCER_FAILURE\"" data/benchmark | wc -l)
num_dependency_lock_failure=$(grep -ro "\"DEPENDENCY_LOCK_FAILURE\"" data/benchmark | wc -l)
num_unreproducible=$(find data/unsuccessful-reproductions -iname "*.json" | wc -l)
num_reproduced=$(find data/benchmark -iname "*.json" | wc -l)
num_attempted=$(("$num_reproduced" + "$num_unreproducible"))
num_not_attempted=$(find data/in-progress-reproductions -iname "*.json" | wc -l)
num_unique_projects=$(jq -r '"\(.projectOrganisation)/\(.project)"' data/benchmark/*.json | sort -u | wc -l)

# Create STATS variable to use in the README.
STATS="## Stats
As of $(LC_TIME=en_US.UTF-8 date +"%b %-d %Y"):
  * The benchmark consists of $num_reproduced reproducible breaking updates from $num_unique_projects unique projects.
    - Of these breaking updates, $num_compilation_failure ($(get_fraction_as_percentage "$num_compilation_failure" "$num_reproduced")) fail compilation with the updated dependency.
    - $num_test_failure ($(get_fraction_as_percentage "$num_test_failure" "$num_reproduced")) fail tests with the updated dependency.
    - $num_dependency_resolution_failure ($(get_fraction_as_percentage "$num_dependency_resolution_failure" "$num_reproduced")) have dependency resolution failures with the updated dependency.
    - $num_enforcer_failure ($(get_fraction_as_percentage "$num_enforcer_failure" "$num_reproduced")) fail after updating the dependency due to enforcer failures.
    - $num_dependency_lock_failure ($(get_fraction_as_percentage "$num_dependency_lock_failure" "$num_reproduced")) fail due to dependency locks.
  * Overall, reproduction has been attempted for $num_attempted breaking updates, and $num_unreproducible ($(get_fraction_as_percentage "$num_unreproducible" "$num_attempted")) could not be locally reproduced.
  * For $num_not_attempted potential breaking updates, reproduction has not been attempted yet."
export STATS
