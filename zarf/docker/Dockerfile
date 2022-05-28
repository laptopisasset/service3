FROM golang as build_sales-api
ENV CGO_ENABLED 0
ARG BUILD_REF


COPY . /service

WORKDIR /service
RUN go build -ldflags="-X main.build=${BUILD_REF}"


FROM alpine
ARG BUILD_DATE
ARG BUILD_REF
WORKDIR /service
COPY --from=build_sales-api /service/service3 .
CMD ["./service3"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.title="sales-api" \
    org.opencontainers.image.authors="Soundhar Natarajan <laptopisasset@gmail.com>" \
    org.opencontainers.image.source="https://github.com/laptopisasset/service3/app/sales-api" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.vendor="Soundhar"
