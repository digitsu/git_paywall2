# GitPaywall2

A proof-of-concept Elixir application that implements a paywall for Git repositories using Bitcoin SV micropayments.

## Features

* Repository access control via micropayments
* Bitcoin SV payment processing
* Temporary access token generation
* RESTful API for repository management
* Python client for interacting with the paywall

## Installation and Setup

### Prerequisites

* Elixir 1.13 or later
* PostgreSQL
* Git

### Database Setup

1. Make sure PostgreSQL is running
2. Configure your database credentials in `config/dev.exs`
3. Create and migrate your database with:

```shell
mix ecto.create
mix ecto.migrate
```

4. Seed the database with sample data:

```shell
mix run priv/repo/seeds.exs
```

### Running the Application

Start the Phoenix server:

```shell
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## API Endpoints

* `GET /api/repos/:repo_id` - Get repository information
* `GET /api/repos/:repo_id/clone` - Access repository (requires payment if not already paid)
* `POST /api/repos/:repo_id/price` - Set repository price (owner only)

## Python Client Usage

```bash
# Clone a repository
python clients/python/git_paywall2_client.py clone example-repo

# Clone to a specific directory
python clients/python/git_paywall2_client.py clone example-repo --destination my-repo
```

## Development

### Running Tests

```shell
mix test
```

### Code Structure

* `lib/git_paywall2/` - Core application logic
  * `accounts/` - User account management
  * `repositories/` - Repository management
  * `payments/` - Payment processing
  * `access_control/` - Repository access control
  * `bsv/` - Bitcoin SV integration
* `lib/git_paywall2_web/` - Web interface and API
* `priv/repo/migrations/` - Database migrations
* `test/` - Test files

## License

This project is licensed under the MIT License.