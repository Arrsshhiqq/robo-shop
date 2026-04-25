FROM maven:3.8-openjdk-8-slim AS build

WORKDIR /opt/shipping
COPY pom.xml .
RUN mvn dependency:resolve
COPY src ./src
RUN mvn package -DskipTests

FROM alpine:latest

EXPOSE 8080

WORKDIR /opt/shipping

ENV CART_ENDPOINT=cart:8080
ENV DB_HOST=mysql

RUN apk add --no-cache openjdk8-jre

COPY --from=build /opt/shipping/target/shipping-1.0.jar shipping.jar

CMD ["java", "-Xmn256m", "-Xmx768m", "-jar", "shipping.jar"]
