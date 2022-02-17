FROM alpine:3.15
RUN apk --no-cache add wget bash pcre2-tools
WORKDIR /books
CMD ["/bin/bash", "/books/books.sh"]