# Class: artifactory
# ===========================
#
# Full description of class artifactory here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class artifactory {

  # validate parameters here

  class { '::artifactory::install': } ->
  class { '::artifactory::config': } ~>
  class { '::artifactory::service': } ->
  Class['::artifactory']
}
