FROM nginx:1.28-alpine
ARG SET_NUMBER
ARG BUILD_NUMBER
ARG CREATED_AT
LABEL org.opencontainers.image.title="Kubernetes practical set ${SET_NUMBER}" \
      org.opencontainers.image.created="${CREATED_AT}" \
      practical.set="${SET_NUMBER}" \
      practical.build="${BUILD_NUMBER}"
COPY exercise/ /opt/kubernetes-practical/exercise/
COPY build.json /usr/share/nginx/html/build.json
