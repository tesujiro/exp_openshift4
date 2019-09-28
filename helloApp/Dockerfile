FROM alpine
MAINTAINER tesujiro <tesujiro@gmail.com>
RUN echo "now building..."
ADD ./hello.linux /hello
ADD ./public /public
#ADD ./ssl /ssl
EXPOSE 80
#EXPOSE 443
ENTRYPOINT ["/hello"]
