FROM debian:latest as builder
# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    sed \
    && apt-get clean
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN cd /usr/local/flutter && git checkout 3.27.3
RUN flutter doctor
RUN flutter config --enable-web
WORKDIR /app

# Copy only pubspec files first
COPY pubspec.* ./
RUN flutter pub get

# Then copy the rest of the code
COPY . .
RUN flutter pub run build_runner build
RUN flutter build web

FROM httpd:2.4
COPY --from=builder /app/build/web /usr/local/apache2/htdocs/