# Rails with Blockstack Tutorial

This tutorial will walk you through the process of creating a Ruby on Rails application that uses Blockstack authentication. After following this tutorial, you'll have everything setup to use this authentication with a full Ruby on Rails website.

We'll setup Blockstack authentication by using [`OmniAuth`](https://github.com/OmniAuth/OmniAuth), which is a popular framework for integrating third-party authentication with a ruby on rails website. We provide an OmniAuth plugin, [`OmniAuth-blockstack`](https://github.com/blockstack/OmniAuth-blockstack) to make this easy for you.

This tutorial assumes you have a basic understanding of ruby and ruby on rails. If this is your first time with rails, you might want to check out the [ruby on rails documentation](https://rubyonrails.org/) and learn more about it. We'll explain concepts as we go along that is beginner-friendly, but having a basic understanding of rails will help.

## Setup

First, you'll need ruby installed on your machine. I recommend using [`rvm`](https://rvm.io/), which helps you easily install and use different versions of Ruby on your computer.

After installing `rvm`, by following the instructions on the website, install a version of ruby that is at least `2.0`. To see your current ruby version:

~~~bash
ruby -v
~~~

To install a newer version of ruby, run:

~~~bash
rvm install 2.5.1
~~~

Next, you need to install the `rails` gem:

~~~
gem install rails
~~~

This should install Ruby on Rails version 5.2.1, which is the version this tutorial was built in. If you're using a different version of ruby or rails, you should still have no problem following this tutorial.

Once you've installed rails, create a new rails project by using the `rails new` command:

~~~bash
rails new blockstack-rails-example
~~~

This will generate a new rails project with a full folder setup. After installing, switch to the new project, and open the new folder in your code editor:

~~~bash
cd blockstack-rails-example
~~~

You can now run your rails server using the `rails s` command, where "s" is an alias for `server`.

~~~bash
rails s
~~~

After running that command, you can open [`http://localhost:3000/`](http://localhost:3000/), and you should see the default homepage that says "Yay! You're on Rails!".

## Installing OmniAuth and OmniAuth-blockstack

You'll need to add two gems to your project to use OmniAuth and blockstack. To install them, first open the `Gemfile` file in the root of your project, and add these two lines:

~~~ruby
gem 'omniauth'
gem 'omniauth-blockstack'
~~~

Then, in the command line, run `bundle install` to finish installing the gems.

**Note**: If you see an error message that looks like `"Your Ruby version is 2.0.0, but your Gemfile specified 2.5.1"`, this is because the auto-generated `Gemfile` includes a line that specifies which ruby version this project needs to use. You can either switch to that version by running `rvm use 2.5.1`, or by removing the line `ruby '2.5.1'` from your Gemfile.

You'll now need to add some code to your project to configure the OmniAuth gem and the Blockstack plugin. Create a new file at `config/initializers/omniauth.rb`, and add the following code:

~~~ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :blockstack
end
~~~

This adds the OmniAuth middleware to your rails project, and tells OmniAuth to use the Blockstack provider.

## Adding a homepage

You'll need to setup a new homepage for your application. We'll create a new controller, called `PagesController`, that includes the homepage. To set this up, run:

~~~bash
rails generate controller pages home
~~~

This uses the `rails generate` command, and tells it to create a `controller` names `pages`, that includes the method `home`. After running this, you'll have a few new files:

- `/app/controllers/pages/pages_controller.rb` - this is the new controller you created, with a `home` method
- `/app/views/pages/home.html.erb` - this is the template that rails will use to render the view for `home`.

This command also modifies the file `/config/routes.rb` and adds configures your server to use the `home` method for the route `/pages/home`.

We want to make this method our homepage, which means we need to change the `root` of our server. Open up `/config/routes.rb` file and modify it to include the look like this:

~~~ruby
Rails.application.routes.draw do
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
~~~

We've called the `root` method with the `to` option, telling rails to use the `home` method in the `pages` controller as the homepage. If you open up your [homepage](http://localhost:3000/), you should see the newly generated view.

## Adding an OmniAuth callback for Blockstack

After a user signs in with OmniAuth, you need to specify a `callback` method for handling the rest of the sign in flow. This is typically where you grab the authentication information from the third party, save some data, and sign the user in to your application by saving information in cookies.

We're going to add a callback for Blockstack, and in that method, we'll simply save their Blockstack profile to a cookie that we can use later on.

To do this, add a new method in `PagesController` called `blockstack_callback`. Add a new method inside of `/app/controllers/pages_controller.rb` that looks like this:

~~~ruby
def blockstack_callback
  blockstack_info = env['omniauth.auth']
  session[:blockstack_user] = blockstack_info
  redirect_to '/'
end
~~~

A few things are happening here. We're getting the user's Blockstack info from `env['omniauth.hash`], which is where omniauth stores all authentication info. We then add that info into the `session` object under the key `:blockstack_user`. By adding this info to the session, it will be saved in a cookie, and will be easy to reference later on.

We also need to configure a route to handle this callback. In the `routes.rb` file, add a line that looks like this:

~~~ruby
get '/auth/blockstack/callback' => 'pages#blockstack_callback'
~~~

This tells your server to invoke the `blockstack_callback` method when the user visits `/auth/blockstack/callback`. By default, OmniAuth redirects the user to `/auth/:provider/callback` whenever the users comes back from a third-party login.

## Updating the homepage

We want to modify the homepage to direct the user to sign in with Blockstack. Open up `/app/views/pages/home.html.erb`, and modify the HTML to look like this:

~~~html
<a href="/auth/blockstack">Log In with Blockstack</a>
~~~

We've simply created a link to the route `/auth/blockstack`. By default, OmniAuth adds routes to your application in the form of `/auth/:provider`. When the user visits that page, they're redirected through the third part authentication flow.

If you refresh your homepage and click the link, you should be redirected to the Blockstack Browser to approve the sign-in flow.

After you finish signing in with the Blockstack Browser, you'll be redirected back to your homepage, with their Blockstack information stored in the `session`. You can now add another line to your homepage to view this information. Inside `/app/views/pages/home.html.erb`, add a line of code that looks like this:

~~~erb
<%= debug session[:blockstack_user] %>
~~~

This is a special tag that tells rails to output the variable `session[:blockstack_user]` in an easy-to-read format.

If you refresh the homepage, you'll see all the information that you got back from Blockstack, including profile information and a private key that you can use to encrypt data and interact with [Gaia](https://github.com/blockstack/gaia).

## Conclusion

Congratulations! You've successfully integrated Blockstack authentication into your rails application. You can now build out a fully-fledged rails app with the ability to use Blockstack for decentralized user authentication.




