# Stage 1: prepare the static site (build context stays out of the final image)
FROM alpine:3.20 AS builder
WORKDIR /src
COPY index.html .

# Stage 2: tiny runtime image — only nginx + the built file
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /src/index.html /usr/share/nginx/html/index.html
EXPOSE 8080
