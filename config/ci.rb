# Rails 8.1 Local CI
# Run with: bin/ci
#
# Defines a local continuous integration pipeline that runs style, security,
# and test steps in sequence. This replaces the need for a cloud CI provider
# for small-to-mid-sized applications.

CI.run do
  step "Setup",            "bin/setup --skip-server"

  step "Style: Brakeman",  "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"

  step "Security: Gem audit", "bundle-audit check"

  step "Tests: Unit",      "bin/rails test"
  step "Tests: System",    "bin/rails test:system"
  step "Tests: Seeds",     "env RAILS_ENV=test bin/rails db:seed:replant"
end
