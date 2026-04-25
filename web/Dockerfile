FROM nginx:alpine

EXPOSE 8080

ENV CATALOGUE_HOST=catalogue \
    USER_HOST=user \
    CART_HOST=cart \
    SHIPPING_HOST=shipping \
    PAYMENT_HOST=payment \
    RATINGS_HOST=ratings

COPY static /usr/share/nginx/html
RUN cp /usr/share/nginx/html/empty.html /usr/share/nginx/html/eum.html

COPY default.conf.template /etc/nginx/templates/default.conf.template
RUN sed -i '1,3d' /etc/nginx/templates/default.conf.template
