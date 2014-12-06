# TaskHelper

Offers a clean Ruby interface for interacting with
the MyTaskHelper.com API.

Includes wrapper classes for Database, Form, Field, and Record.
These classes offer shorthand methods for common API calls, as
well as convenient methods to read the data returned from the API.

Also includes an `API` module, which can be used to directly access
any available route in the API.

## Installation

Add this line to your application's Gemfile:

    gem 'task_helper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install task_helper

## Usage

### Resources

TaskHelper provides a ruby interface to four MyTaskHelper resources:

* Database
* Form
* Field
* Record

This gem offers classes to interact with each of these resources in
an ActiveRecord like fashion. Each class contains methods for fetching
objects from the API, readers for attributes of retrieved objects,
and methods to navigate between related resources.

#### Database

This class offers functionality to retrieve and interact with databases
in MyTaskHelper.

##### API Access Methods

The `TaskHelper::Database` class offers singleton methods, which mimic the
functionality of their ActiveRecord counterparts.

###### All

`TaskHelper::Database.all` returns an Array of all databases returned from
'mytaskhelper.com/apps.json'.

    TaskHelper::Database.all # GET 'apps.json'
    => [#<TaskHelper::Database>, ...]

###### Find

`TaskHelper::Database.find` accepts a string corresponding to the id of a
database in MyTaskHelper, and returns the database (if any) found at
'mytaskhelper.com/apps/:id.json'.

    TaskHelper::Database.find('foobar123') # GET 'apps/foobar123.json'
    => #<TaskHelper::Database id: 'foobar123'>

###### Find By

`TaskHelper::Database.find_by` accepts a hash of search parameters, passes those
parameters to the 'mytaskhelper.com/apps/search.json' route, and returns the
corresponding database (if any are found).

    TaskHelper::Database.find_by(name: 'Foo Bar') # GET 'apps/search.json?name=Foo%20Bar'
    => #<TaskHelper::Database name: 'Foo Bar'>

##### Attributes

A database object contains the following attributes:

* id
* name
* dtypes_count
* entities_count
* properties_count
* created_at
* updated_at

##### Relations

`TaskHelper::Database` objects respond to the `.forms` method, which returns
and Array of `TaskHelper::Forms` associated with that database.

    database = TaskHelper::Database.find('foobar123')
    database.forms # GET 'apps/foobar123/entities.json'
    => [#<TaskHelper::Form app_id: 'foobar123'>, ...]

## Contributing

1. Fork it ( http://github.com/xDAGRONx/task_helper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
