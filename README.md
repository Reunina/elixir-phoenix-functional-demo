# ElixirPhoenixFunctionalDemo

Little Elixir-Phoenix app for training purposes

## Functional description

This project exposes a small user-oriented API and a home page.

- The `GET /users` endpoint returns users ordered by full name (`first_name`, then `last_name`).
- Users can be filtered by:
  - `name` (matches first name, last name, or full name, case-insensitive)
  - `has_active_product` (`true`/`false`)
- The `POST /users/invite-users` endpoint finds users with active products and triggers a background invitation workflow.
- The response of the invite endpoint includes the number of invited users and their IDs.
- An interactive Swagger UI is available at `/swagger` for manual API exploration and testing.

## Technical description

ElixirPhoenixFunctionalDemo is a Phoenix `1.8` application written in Elixir (`~> 1.15`) with a PostgreSQL persistence layer via Ecto.

- **Web layer:** Phoenix router/controller architecture with JSON APIs under `/users` and an HTML home route at `/`.
- **API documentation:** `phoenix_swagger` is used to describe endpoints and schemas, and the generated docs are served through `PhoenixSwagger.Plug.SwaggerUI`.
- **Domain behavior:** `ElixirPhoenixFunctionalDemoWeb.UserController` builds filter/order options and delegates user retrieval to a configurable users context (`:users_context`, defaulting to `ElixirPhoenixFunctionalDemo.Users`).
- **Asynchronous work:** the invitation endpoint starts a background task (`Task.start/1`) and dispatches fake emails through `ElixirPhoenixFunctionalDemo.FakeMailer`.
- **Tooling and assets:** Tailwind CSS + esbuild for frontend assets, Bandit as the HTTP server, and a `mix precommit` alias for compile/format/test checks.

## To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Swagger 

Using [swagger](https://swagger.io/) for api documentation and manual testing.

to generate the swagger documentation  
````
mix phx.swagger.generate
````

Now you can visit [`localhost:4000/swagger/index/html`](http://localhost:4000/swagger/index.html#/Users) after running your project

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix  