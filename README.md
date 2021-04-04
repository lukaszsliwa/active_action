[![ActiveAction](https://raw.githubusercontent.com/lukaszsliwa/active_action/main/intro2.png)](https://github.com/lukaszsliwa/active_action/)


[![Gem Version](https://badge.fury.io/rb/ruby-active_action.svg)](https://badge.fury.io/rb/ruby-active_action)
[![License MIT](https://img.shields.io/github/license/lukaszsliwa/active_action)](https://github.com/lukaszsliwa/active_action/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/lukaszsliwa/active_action)](https://github.com/lukaszsliwa/active_action/issues)

# ActiveAction

A simple way to build and use Service Objects in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-active_action', '~> 3.0.2'
```

or use alternative gems:

* [rails-active_action](https://github.com/lukaszsliwa/rails-active_action)
* [cuba-active_action](https://github.com/lukaszsliwa/cuba-active_action)
* [grape-active_action](https://github.com/lukaszsliwa/grape-active_action)
* [hanami-active_action](https://github.com/lukaszsliwa/hanami-active_action)
* [nyny-active_action](https://github.com/lukaszsliwa/nyny-active_action)
* [padrino-active_action](https://github.com/lukaszsliwa/padrino-active_action)
* [ramaze-active_action](https://github.com/lukaszsliwa/ramaze-active_action)
* [roda-active_action](https://github.com/lukaszsliwa/roda-active_action)
* [sinatra-active_action](https://github.com/lukaszsliwa/sinatra-active_action)

And then execute:

    $ bundle install

## ActiveAction example

```ruby
# app/actions/application_action.rb
class ApplicationAction < ActiveAction::Base
end

# app/actions/my_action.rb
class MyAction < ApplicationAction
  def perform
    # Your code here
  end
end

# app/controllers/my_controller.rb
class MyController < ApplicationController
  def create
    MyAction.perform # or MyAction.perform!
  end
end
```

`perform!` raises an error if occurred.

```ruby
# app/actions/application_action.rb
class ApplicationAction < ActiveAction::Base
end

# app/actions/my_action.rb
class MyAction < ApplicationAction
  def perform
    # Your code here
    error!(message: 'Example error message')
  end
end

# app/controllers/my_controller.rb
class MyController < ApplicationController
  def create
    MyAction.perform! # it will raise ActiveAction::Error
  end
end
```

## Demo

```ruby
# app/actions/create_user_action.rb
class CreateUser < ActiveAction::Base
  attributes :user
  
  after_perform :send_email_on_success, on: :success
  
  def perform(company, params)
    self.user = company.users.build(params)
    if self.user.save
      success!
    else
      error!
    end
  end
  
  def send_email_on_success
    UserMailer.with(user: self.user).welcome.deliver_later
  end
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def create
    context = CreateUser.perform(current_company, params_user)
    
    respond_to do |format|
      if context.success?
        format.html { redirect_to dashboard_path, notice: 'Welcome to our app' }
      else
        format.html { render action: :new } 
      end
    end
  end
  
  private
  
  def params_user
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
  
  def current_company
    @company ||= Company.find_by!(subdomain: request.subdomain)
  end
end
```

## Callbacks

On `success` or `error`:
* `after_perform`
* `before_perform`
  
```ruby
# app/actions/create_post.rb
class CreatePost < ActiveAction::Base
  before_perform do
    # run a code before perform within a block
  end
  
  after_perform do
    # run a code after perform within a block
  end
  
  after_perform :run_success_callback, on: :success
  after_perform :run_error_callback, on: :error
  
  def perform(user, params: {})
    @post = user.posts.build(params)
    
    if @post.save
      success!(message: 'Post was successfully created.')
    else
      error!(message: @post.errors.full_messages.join(' '))
    end
  end

  protected
  
  def run_success_callback
    PostMailer.with(post: @post).success.deliver_later
  end
  
  def run_error_callback
    PostMailer.with(post: @post).error.deliver_later
  end
end
```

* `around_perform`

```ruby
# app/actions/run_process.rb
class RunProcess < ActiveAction::Base
  around_perform :measure
  
  def measure
    @start = Time.current
    yield
    @end = Time.current
  end
  
  def perform(id)
    `#{Process.find(id).command}`
  end
end
```

## Statuses

Call `success!`, `succeed!`, `done!`, `correct!`, `ready!`, `active!` if the action performed successfully or `error!`, `fail!`, `failure!`, `failed!`, `invalid!`, `incorrect!`, `inactive!` otherwise.

```ruby
# app/actions/run.rb
class Run < ActiveAction::Base
  def perform
    if (@value = rand(100)) % 2 == 0
      success!
    else
      fail!
    end
  end
  
  after_perform :send_email_on_success
  
  def send_email_on_success
    RunnerMailer.set(value: @value).deliver_later if success?
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lukaszsliwa/active_action. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lukaszsliwa/active_action/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveAction project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lukaszsliwa/active_action/blob/master/CODE_OF_CONDUCT.md).
