Each folder is a Hello World web app with a Dockerfile. nodejs-app is Express on port 3000. python-app is Flask on 5000. java-app is a Java HTTP server on 8080. Apache-app is httpd on host port 8081. React-app is Vite on 5173. nginx-app is nginx on host port 8082.

Docker is not on this Windows machine. Build and run on a machine that has Docker, for example the homelab.

Example for node: docker build -t homework-nodejs . then docker run -d --name homework-nodejs -p 3000:3000 homework-nodejs. Same pattern for the others with their ports. curl localhost on that port should show the Hello World line. docker ps lists the running containers.
