name: tests
on:
  push:
    branches:
      - {{ .Git.DefaultBranch }}
  pull_request:

permissions:
  contents: read

concurrency:
  group: {{ "${{ github.workflow }}-${{ github.head_ref }}" }}
  cancel-in-progress: true

{{- if (eq (stencil.Arg "vcs") "forgejo") }}

env:
	# When on VCS providers other than Github (e.g., forgejo), this is
	# used to reflect a Github Token that actually has access to Github,
	# unlike the token provided by act.
	#
	## <<Stencil::Block(forgejoGithubToken)>>
	REAL_GITHUB_TOKEN: {{ (file.Block "forgejoGithubToken" | default "REAL_GITHUB_TOKEN: ''" | fromYaml).REAL_GITHUB_TOKEN | default "${{ github.token }}" }}
	## <</Stencil::Block>>
{{- end }}

jobs:
  gotest:
    name: go test
    runs-on: ubuntu-latest
    steps:
      {{- /* renovate: datasource=github-tags packageName=actions/checkout */}}
      - uses: actions/checkout@v6
			{{- /* renovate: datasource=github-tags packageName=jdx/mise-action */}}
      - uses: jdx/mise-action@v3
        with: {{ eq (stencil.Arg "vcs") "github" | ternary "{}" "" }}
				{{- if (eq (stencil.Arg "vcs") "forgejo") }}
          github_token: {{ "${{ env.REAL_GITHUB_TOKEN }}"}}
				{{- end }}
      - name: Get Go directories
        id: go
        run: |
          echo "cache_dir=$(go env GOCACHE)" >> "$GITHUB_OUTPUT"
          echo "mod_cache_dir=$(go env GOMODCACHE)" >> "$GITHUB_OUTPUT"
      {{- /* renovate: datasource=github-tags packageName=actions/cache */}}
      - uses: actions/cache@v5
        with:
          path: {{ "${{" }} steps.go.outputs.cache_dir {{ "}}" }}
          key: {{ "${{" }} runner.os {{ "}}" }}-go-build-cache-{{ "${{" }} hashFiles('**/go.sum') {{ "}}" }}
      {{- /* renovate: datasource=github-tags packageName=actions/cache */}}
      - uses: actions/cache@v5
        with:
          path: {{ "${{" }} steps.go.outputs.mod_cache_dir {{ "}}" }}
          key: {{ "${{" }} runner.os {{ "}}" }}-go-mod-cache-{{ "${{" }} hashFiles('go.sum') {{ "}}" }}
      - name: Download dependencies
        run: go mod download
      - name: Run go test
        env: {{ empty (file.Block "gotestEnvVars") | ternary "{}" "" }}
					## <<Stencil::Block(gotestEnvVars)>>
{{ file.Block "gotestEnvVars" }}
					## <</Stencil::Block>>
        run: gotestsum -- -coverprofile=cover.out ./...
			{{- if (eq (stencil.Arg "vcs") "github") }}
      - name: Upload test coverage
        {{- /* renovate: datasource=github-tags packageName=codecov/codecov-action */}}
        uses: codecov/codecov-action@v5
        with:
          token: {{ "${{" }} secrets.CODECOV_TOKEN {{ "}}" }}
          files: ./cover.out
          fail_ci_if_error: true
			{{- end }}

  golangci-lint:
    name: golangci-lint
    runs-on: ubuntu-latest
    steps:
      {{- /* renovate: datasource=github-tags packageName=actions/checkout */}}
      - uses: actions/checkout@v6
			{{- /* renovate: datasource=github-tags packageName=jdx/mise-action */}}
      - uses: jdx/mise-action@v3
        with: {{ eq (stencil.Arg "vcs") "github" | ternary "{}" "" }}
				{{- if (eq (stencil.Arg "vcs") "forgejo") }}
          github_token: {{ "${{ env.REAL_GITHUB_TOKEN }}"}}
				{{- end }}
      - name: Retrieve golangci-lint version
        run: |
          echo "version=$(mise current golangci-lint)" >> "$GITHUB_OUTPUT"
        id: golangci_lint
      - name: golangci-lint
        {{- /* renovate: datasource=github-tags packageName=golangci/golangci-lint-action */}}
        uses: golangci/golangci-lint-action@v9
        with:
          version: v{{ "${{" }} steps.golangci_lint.outputs.version {{ "}}" }}
          args: --timeout=30m
