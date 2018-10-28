# pizza-express-deployment
## Automatic deployment of Pizza-Express application

### Brief description:
This project was created to deploy of Pizza-Express application automatically. Pizza-Express application is based on Node.js and Redis database.

### About the make-self-extract archive file
The make-self-extract archive file `pizza_express_deployment.run` contains inside the `pizza_express_deployment.sh` script and the `docker-compose.yml`.
You can extract the `pizza_express_deployment.run` archive by running it with `--keep` and `--noexec` parameters:
```
# sh pizza_express_deployment.run --keep --noexec
```
It will extract the `pizza-compose` directory.

You can read how to create and manipulate with the make-self-extract archive on:
[Make-self-extract archive file](https://makeself.io/)
[GitHub project](https://github.com/megastep/makeself)


### How to run the Pizza-Express deployment:

To run the deployment you just need to run the 'pizza_express_deployment.run' file:
```
# sh pizza_express_deployment.run
```

Or you can set an executable permissions and run it directly:
```
# ./pizza_express_deployment.run
```

After the deployment finished you can do an additional run of the uni-tests by the following command:
```
# docker run --rm -ti --net pizza_new_net dimab07/pizza-express npm test
```

### Prerequisites:

The Pizza-Express deployment has the following prerequisites:
1. The docker and docker-compose should be installed.
2. You should run the deployment as root user.
The deployment script is verifying these prerequisites.

### Additional information about the project on GitHub and DockerHub:

1. The Dockerfile of pizza-express image is located in the 'pizza-express-docker-image' directory of the project.
2. The images location on DockerHub:
  `docker.io/dimab07/pizza-redis`
  `docker.io/dimab07/pizza-express`
