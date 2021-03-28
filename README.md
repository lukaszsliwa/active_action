# ActiveAction

A simple way to build and use Service Objects in Ruby on Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-active_action'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rails-active_action

## ActiveAction example

```ruby
# app/actions/my_action.rb
class MyAction < ActiveAction::Base
  def perform
    # Your code here
  end
end

# app/controllers/my_controller.rb
class MyController < ApplicationController
  def create
    MyAction.perform
  end
end
```

or `perform!` to raise an error if occurred.

```ruby
# app/actions/my_action.rb
class MyAction < ActiveAction::Base
  def perform
    # Your code here
    error!
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
    User.welcome.with(user: self.user).deliver
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
  
  after_perform :run_callback, on: :success
  after_perform :run_warning_email, on: :error
  
  def perform(user, params: {})
    # your code here
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
    if rand(100) % 2 == 0
      success!
    else
      fail!
    end
  end
  
  after_perform :send_email_on_success
  
  def send_email_on_success
    Mail.deliver! if success?
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lukaszsliwa/active_action. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lukaszsliwa/active_action/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveAction project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lukaszsliwa/active_action/blob/master/CODE_OF_CONDUCT.md).
