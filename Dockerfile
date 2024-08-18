# --- Build the app ---
FROM node:22-alpine AS build
COPY . /usr/src/fabriquepar
WORKDIR /usr/src/fabriquepar
ARG APP_URL=fabriquepar

# Create .env file
RUN echo "VITE_API_ENDPOINT=\"http://${APP_URL}/api\"" > .env && \
    echo "VITE_IMAGE_BASE_URL=\"http://{$APP_URL}\"" >> .env && \
    echo "VITE_STRIPE_KEY=pk_test_PZ5P8UpDWL0CqulY6YJjRzGo00vQtn1Ff3" >> .env && \
    echo "VITE_STRIPE_SECRET=sk_test_sgFQbF0KnQt7Me5J852syFSJ00GklPEL7C" >> .env

RUN npm install
RUN npm run build

# --- Run the app ---
FROM nginx:1.26.2
COPY --from=build /usr/src/fabriquepar/dist usr/share/nginx/html/fabriquepar
COPY --from=build /usr/src/fabriquepar/configuration/nginx.conf /etc/nginx/conf.d/default.conf

# Give ownership to root group (GID : 0) for rootless usage
RUN chgrp -R root /usr/share/nginx && chmod -R g+rwX /usr/share/nginx && \
    chgrp -R root /var/cache/nginx && chmod -R g+rwX /var/cache/nginx &&\
    chgrp -R root /etc/nginx && chmod -R g+rwX /etc/nginx &&\
    chgrp -R root /var/log/nginx && chmod -R g+rwX /var/log/nginx

RUN touch /var/run/nginx.pid && \
    chgrp -R root /var/run/nginx.pid && chmod -R g+rwX /var/run/nginx.pid

USER 1001:root

EXPOSE 8080