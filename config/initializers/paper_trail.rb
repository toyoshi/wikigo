PaperTrail.config.track_associations = false

# Store serialized versions as JSON rather than YAML.
#
# The YAML serializer breaks PaperTrail#reify on Ruby 4.0 / Psych 4: versioned
# attributes dump native classes (Time, ActiveSupport::TimeWithZone,
# ActiveSupport::TimeZone, ...) and Psych's safe load raises
# Psych::DisallowedClass for anything outside its permit list, so version
# history could not be deserialized (issue #82). JSON avoids Psych entirely:
# versioned attributes round-trip as plain strings and reify correctly.
PaperTrail.serializer = PaperTrail::Serializers::JSON
