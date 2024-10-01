Migrate from Heroku
FAQ
Service types
Which to use?
Static sites
Web services
Private services
Background workers
Cron jobs
How deploys work
Supported languages
Build pipeline
Deploy hooks
Troubleshooting deploys
Git providers
GitHub
GitLab
Bitbucket
Deploying a specific commit
Monorepo support
Docker images
Docker on Render
Deploy from a registry
Using secrets
Runtime
Native runtimes
Environment variables & secrets
Default environment variables
Persistent disks
Redis
PostgreSQL databases
Creating & connecting
Backups & recovery
Read replicas
High availability
Admin apps
Extensions
Connection pooling
Upgrading your version
Troubleshooting performance
Regions
Private network
Outbound IPs
TLS certificates
DDoS protection
Custom domains
Overview
Cloudflare
Namecheap
Other DNS providers
Projects & environments
Service operations
Scaling
Service previews
Rollbacks
Maintenance mode
One-off jobs
Infrastructure as code
Blueprints overview
render.yaml reference
Preview environments
Metrics
Notifications
Uptime best practices
Logging
In-dashboard logs
Stream to your provider
Workspaces, members, & roles
Enforcing secure login
Audit logs
SSH
Overview
Generate a key
Add a key
Troubleshooting SSH
Render API
Overview
API reference
CLI (alpha)
Third-party tools
Datadog
Scout APM
Stripe
QuotaGuard Static IP
Formspree

    Quickstarts
    Rails

Deploying Ruby on Rails on Render

This guide demonstrates how to set up a local Ruby on Rails 7 environment, create an app with a simple view, and deploy that app to Render. It also shows how to connect the app to a Render PostgreSQL database.
1. Create a Rails project

If you have an existing Rails project that you want to deploy to Render, you can skip to Update your app for Render.

First, let’s set up a local development environment with a basic project structure.
Install Rails

Use the gem install command to install Rails if you haven’t yet. Make sure you have the required dependencies installed (Ruby, Node.js and Yarn 1.x).

gem install rails

We’re using Rails 7.1 in this tutorial, so verify that you have the correct version installed:

rails --versionRails 7.1.2

Create a new project

This tutorial creates a Rails project with the name mysite. You can replace this name with another name of your choosing.

    In your terminal, navigate to the directory where you’ll create your project. Then, run the following command to generate a new project that uses Bootstrap for styling:

rails new mysite --database=postgresql -j esbuild --css bootstrap

You can provide additional arguments to customize the generated project. Run rails new -h for details.

Create local PostgreSQL databases for your app:

    rails db:createCreated database 'mysite_development'
    Created database 'mysite_test'

    If this command fails, make sure you’ve installed and started PostgreSQL locally, then check your project’s config/database.yml file. You might need to specify your PostgreSQL username and/or password.

You should now have a functional foundation for your new Rails app! To verify, start your development server:

bin/dev

To see your app in action, go to localhost:3000 in your browser. You should see the Rails default landing page:

Rails Successful Installation

Commit all of your project changes and push them to a repository on GitHub/GitLab/Bitbucket. You can deploy your app to Render from any of these.
2. Create the Hello World landing page

Next, let’s add a simple static view to your app.

See the official Getting Started with Rails guide for more on creating Rails apps.

    To create a new Rails controller, you run the controller generator. Set the controller’s name to Render and set up an action named index by running the following command:

    rails g controller Render index

    The generator creates several files in your project:

    create  app/controllers/render_controller.rb
     route  get 'render/index'
    invoke  erb
    create    app/views/render
    create    app/views/render/index.html.erb
    invoke  test_unit
    create    test/controllers/render_controller_test.rb
    invoke  helper
    create    app/helpers/render_helper.rb
    invoke    test_unit

    Open the config/routes.rb file and add the following line:

    Rails.application.routes.draw do
       get 'render/index'
       # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

       # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
       # Can be used by load balancers and uptime monitors to verify that the app is live.
       get "up" => "rails/health#show", as: :rails_health_check

       # Defines the root path route ("/")
       root "render#index"end

    Open the app/views/render/index.html.erb file and replace its contents with the following:

    <main class="container">
      <div class="row text-center justify-content-center">
        <div class="col">
          <h1 class="display-4">Hello World!</h1>
        </div>
      </div>
    </main>

Verify your changes by returning to localhost:3000 in your browser. If you stopped your local server, restart it first:

bin/dev

Rails Hello World
3. Update your app for Render

Let’s prepare your Rails project for production on Render. We’ll create a build script for Render to run with each deploy, and we’ll update your project to use a Render PostgreSQL database instead of SQLite (if necessary).
Create a build script

Render builds your project before each deploy by running a build command that you specify. Let’s create a script to use for this command.

Create a file named render-build.sh in your repo’s bin directory. Paste the following into it and save:

#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# If you're using a Free instance type, you need to
# perform database migrations in the build command.
# Uncomment the following line:

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
