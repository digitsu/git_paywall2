# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GitPaywall2.Repo.insert!(%GitPaywall2.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias GitPaywall2.Repo
alias GitPaywall2.Accounts.User
alias GitPaywall2.Repositories.Repository

# Create test users
demo_user =
  Repo.insert!(%User{
    username: "demo_user",
    email: "demo@example.com",
    bsv_address: "18nxAxBktHZDrMoJ3NzMjjXhQxYM2rKZWB"
  })

admin_user =
  Repo.insert!(%User{
    username: "admin",
    email: "admin@example.com",
    bsv_address: "12nUYCNhBWMpYQruNrDddb1XuJzjgRXoEY"
  })

# Create repositories
Repo.insert!(%Repository{
  name: "example-repo",
  description: "An example repository with paywall access",
  price: 0.0001,
  owner_id: admin_user.id
})

Repo.insert!(%Repository{
  name: "free-repo",
  description: "A free repository with no paywall",
  price: 0.0,
  owner_id: admin_user.id
})

Repo.insert!(%Repository{
  name: "premium-repo",
  description: "A premium repository with high paywall",
  price: 0.001,
  owner_id: admin_user.id
})
