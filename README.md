# Django Container Stack

This project was built for me to practice and learn python as well as the Django framework. I am aiming to containerize a Django app along with Postgres and make a simple admin + client side application. Mostly from following the [Django tutorial](https://docs.djangoproject.com/en/1.11/intro/tutorial01/). Other goals are running it through Travis CI. If CI is successful I am building the container image and pushing it to dockerhub.

## Notes for reviewer

This is not a complete full fledge purposeful django app. This is just to demonstrate I understand and have familiarized myself with the bits and pieces of the django framework and how to containerize it with postgres. However the road does not end here. Please take a look at the [issues](https://github.com/byronmansfield/django-stack/issues) part of the repository. It will show areas that I would prefer to improve on and hopefully give you some insight on how I work with ticketing and executing tasks.

## Developers Notes

I have made a Makefile for a more automated development process

If you need to build the project

```bash
make build
```

It's mostly for versioning, tagging, and pushing it to dockerhub

## References

I'm mostly following along the [Django tutorial from their documentation](https://docs.djangoproject.com/en/1.11/intro/tutorial01/) and the [Docker tutorial in their documentation](https://docs.docker.com/compose/django/#create-a-django-project)

## Requirements

### For pulling and running the container only

1. Docker
2. Docker Compose
3. git

### For local development
1. python3
2. pip
3. django
4. virtualenv

## Build and run project locally as container from git repository

1. Clone the repository
  ```
  git clone git://github.com:byronmansfield/django-stack.git
  ```

2. Make the wait for postgres bash script executable
  ```
  chmod +x wait-for-postgres.sh
  ```

2. Launch the app and database as containers
  ```
  docker-compose up
  ```

That should be it. Now you should be able to visit 127.0.0.1:8000 in your browser

## Additional tasks

### Make and Run migrations

- Once your stack is up via `docker-compose up` you can make your migrations

  ```
  docker-compose run web python manage.py makemigrations
  ```

- To migrate
  ```
  docker-compose run web python manage.py migrate
  ```

