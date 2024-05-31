name: tests
on:
  push:
    branches:
      - {{ .Git.DefaultBranch }}
  pull_request:

permissions:
  contents: read

concurrency:
  group: {{ .Config.Name }}-build-{{ "${{" }} github.head_ref {{ "}}" }}
  cancel-in-progress: true

jobs:
  gotest:
    name: go test
    runs-on: ubuntu-latest
    steps:
      {{- /* renovate: datasource=github-tags packageName=actions/checkout */}}
      - uses: actions/checkout@v4
      {{- /* renovate: datasource=github-tags packageName=jdx/mise-action */}}
      - uses: jdx/mise-action@v2
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{" }} github.token {{ "}}" }}
      - name: Download dependencies
        run: go mod download
      - name: Run go test
        run: |
          gotestsum -- -coverprofile=cover.out ./...
      - name: Upload test coverage
        {{- /* renovate: datasource=github-tags packageName=codecov/codecov-action */}}
        uses: codecov/codecov-action@v4
        with:
          token: {{ "${{" }} secrets.CODECOV_TOKEN {{ "}}" }}
          files: ./cover.out
          fail_ci_if_error: true

  golangci-lint:
    name: golangci-lint
    runs-on: ubuntu-latest
    steps:
      {{- /* renovate: datasource=github-tags packageName=actions/checkout */}}
      - uses: actions/checkout@v4
      {{- /* renovate: datasource=github-tags packageName=jdx/mise-action */}}
      - uses: jdx/mise-action@v2
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{" }} github.token {{ "}}" }}
      - name: Retrieve golangci-lint version
        run: |
          echo "version=$(mise current golangci-lint)" >> "$GITHUB_OUTPUT"
        id: golangci_lint
      - name: golangci-lint
        {{- /* renovate: datasource=github-tags packageName=golangci/golangci-lint-action */}}
        uses: golangci/golangci-lint-action@v6
        with:
          version: v{{ "${{" }} steps.golangci_lint.outputs.version {{ "}}" }}
          args: --timeout=30m