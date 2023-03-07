# Build builder image
FROM ruby:3.1.3-alpine as builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache \
    build-base \
    postgresql14-dev \
    tzdata \
    yarn

# Copy required files
COPY .ruby-version Gemfile* ./

# Install gems and remove gem cache
RUN bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set frozen 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle config set without 'development test' && \
    bundle install --jobs 4 --retry 3

# Install node packages defined in package.json
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Copy all files to /app (except what is defined in .dockerignore)
COPY . .

# Precompile assets
RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 \
    bundle exec rails assets:precompile

# Copy govuk assets
RUN cp -r node_modules/govuk-frontend/govuk/assets/. public/assets/

# Cleanup to save space in the production image
RUN rm -rf node_modules log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete

# Build runtime image
FROM ruby:3.1.3-alpine

# The application runs from /app
WORKDIR /app

# libpq: required to run postgres, tzdata: required to set timezone
RUN apk add --no-cache libpq tzdata

# Add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# Copy files generated in the builder image
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Create log and tmp
RUN mkdir -p log tmp
RUN chown -R appuser:appgroup db log tmp

# Set user
USER 1000

ARG BUILD_DATE
ARG BUILD_TAG
ARG COMMIT_ID
ENV APP_BUILD_DATE=${BUILD_DATE}
ENV APP_BUILD_TAG=${BUILD_TAG}
ENV APP_GIT_COMMIT=${COMMIT_ID}
