**Heroku: https://todo-mlisivka.herokuapp.com/**
# How to start?
**Clone this repository and install dependecies**

```shell
git clone git@github.com:mlisivka/todo_list.git
cd todo_list/
bundle install
```
**Migrate database**
```shell
rake db:create
rake db:migrate
```
**Start server**
```shell
rails s
```
**And visit *`localhost:3000`***

**Run tests**
```shell
rspec spec
```
