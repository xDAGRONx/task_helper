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
an Array of `TaskHelper::Form`s associated with that database.

    database = TaskHelper::Database.find('foobar123')
    database.forms # GET 'apps/foobar123/entities.json'
    => [#<TaskHelper::Form app_id: 'foobar123'>, ...]

#### Form

This class offers functionality to retrieve and interact with forms
in MyTaskHelper.

##### API Access Methods

The `TaskHelper::Form` class offers singleton methods, which mimic the
functionality of their ActiveRecord counterparts.

###### All

`TaskHelper::Form.all` returns an Array of all forms associated with
any database from 'mytaskhelper.com/apps.json'.

    TaskHelper::Form.all
    => [#<TaskHelper::Form>, ...]

###### Find

`TaskHelper::Form.find` accepts two named parameters: database and form.
Each parameter should be a string corresponding to the id of that resource,
and returns the form (if any) found at
'mytaskhelper.com/apps/:database/entities/:form.json'.

    params = { database: 'foobar123', form: 'baz456' }
    TaskHelper::Form.find(params) # GET 'apps/foobar123/entities/baz456.json'
    => #<TaskHelper::Form id: 'baz456'>

###### Find By

`TaskHelper::Form.find_by` accepts a hash of search parameters, passes those
parameters to the 'mytaskhelper.com/apps/search/entities/search.json' route,
and returns the corresponding form (if any are found).

    search = { database_name: 'Foo Bar', form_name: 'Baz' }
    TaskHelper::Form.find_by(search) # GET 'apps/search/entities/search.json?database_name=Foo%20Bar&form_name=Baz'
    => #<TaskHelper::Form name: 'Baz'>

##### Attributes

A form object contains the following attributes:

* id
* app_id
* name
* desc
* post_action
* position
* sort_by
* asc
* per_page
* allow_delete
* new_widget
* records_widget
* target_page
* allow_database
* send_emails
* settings

##### Relations

`TaskHelper::Form` objects respond to the `.database` method, which returns
the database associated with the form.

    params = { database: 'foobar123', form: 'baz456' }
    form = TaskHelper::Form.find(params)
    form.database # GET 'apps/foobar123.json'
    => #<TaskHelper::Database id: 'foobar123'>

`TaskHelper::Form` objects also respond to the `.fields` method, which returns
an Array of `TaskHelper::Field`s associated with that form.

    params = { database: 'foobar123', form: 'baz456' }
    form = TaskHelper::Form.find(params)
    form.fields # GET 'apps/foobar123/entities/baz456/properties.json'
    => [#<TaskHelper::Field entity_id: 'baz456'>, ...]

`TaskHelper::Form` objects also respond to the `.records` method, which returns
a Lazy Enumerator for fetching the records associated with the form.
The enumerator loops through the pages of records found at
'mytaskhelper.com/apps/:app_id/dtypes/entity/:entity_id.json',
and flattens the results into an Enumerator of `TaskHelper::Record`s.

    params = { database: 'foobar123', form: 'baz456' }
    form = TaskHelper::Form.find(params)
    records = form.records
    => #<Enumerator::Lazy: #<Enumerator::Lazy: 1..5>:flat_map> # 5 pages of records
    records.first(3) # GET 'apps/foobar123/dtypes/entity/baz456.json?page=1'
    => [#<TaskHelper::Record entity_id: 'baz456'>, ...]

## Contributing

1. Fork it ( http://github.com/xDAGRONx/task_helper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
