# PixelPerfect Build Environment
# Multi-stage Docker image for building cross-platform PixelPerfect apps

FROM ubuntu:22.04 AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    openjdk-11-jdk \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Install Android SDK
RUN mkdir -p $ANDROID_HOME && \
    cd $ANDROID_HOME && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip commandlinetools-linux-8512546_latest.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/* cmdline-tools/latest/ && \
    rm commandlinetools-linux-8512546_latest.zip

# Accept Android licenses and install SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Build stage for Android
FROM base AS android-builder
WORKDIR /app
COPY "PixelPerfect Android/" ./
RUN ./gradlew assembleDebug

# Final stage - lightweight runtime
FROM alpine:latest AS runtime
LABEL org.opencontainers.image.source="https://github.com/Lihaila/pixelperfect-project"
LABEL org.opencontainers.image.description="PixelPerfect Cross-Platform Image Optimization Suite"
LABEL org.opencontainers.image.licenses="Proprietary"

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    tzdata

# Copy built artifacts
COPY --from=android-builder /app/app/build/outputs/apk/debug/ /artifacts/android/

# Create version info
RUN echo "PixelPerfect v1.0.0" > /artifacts/version.txt && \
    echo "Build Date: $(date)" >> /artifacts/version.txt

# Set working directory
WORKDIR /artifacts

# Default command
CMD ["ls", "-la"]
