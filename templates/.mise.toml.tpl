{{- /* TODO(jaredallard): Don't put this inside of this file */}}
{{- define "defaultVers" }}
# Bun is used only for prettier.
- bun: "latest"
- git-cliff: "latest"
# renovate: datasource=github-tags depName=golang packageName=golang/go
- golang: "1.22"
# renovate: datasource=github-tags depName=golangci-lint packageName=golangci/golangci-lint
- golangci-lint: "1.60.1"
- goreleaser: "latest"
# renovate: datasource=go packageName=gotest.tools/gotestsum
- go:gotest.tools/gotestsum: "v1.12.0"
- go:golang.org/x/tools/cmd/goimports: "latest"
- go:mvdan.cc/sh/v3/cmd/shfmt: "latest"
- go:github.com/thenativeweb/get-next-version: "latest"
{{- end }}
# Default versions of tools, to update these, set [tools.override]
[tools]
{{- range (fromYaml (stencil.ApplyTemplate "defaultVers")) }}
{{- $key := index (keys .) 0 }}
{{- $val := index . $key }}
{{- if contains ":" $key }}
{{- $key = quote $key }}
{{- end }}
{{ $key }} = "{{ $val }}"
{{- end }}

[tasks.build]
description = "Build a binary for the current platform/architecture"
run = "go build -trimpath -o ./bin/ -v ./cmd/..."

[tasks.changelog]
description = "Generate a changelog for the current version"
outputs = ["CHANGELOG.md"]
run = ["git-cliff --config .cliff.toml --output CHANGELOG.md"]

[tasks.fmt]
alias = "format"
description = "Format code"
run = [
	"go mod tidy",
	"gofmt -s -w .",
	"goimports -w .",
	"shfmt -w .",
	"bun node_modules/.bin/prettier --write '**/*.{json,yaml,yml,md,jsonschema.json}'",
]

[tasks.lint]
description = "Run linters"
run = "golangci-lint run"

[tasks.next-version]
description = """Get the version number that would be released if a release was ran right now.
Pass --rc to get the next release candidate version.
"""
run = ["./.github/scripts/get-next-version.sh"]

[tasks.test]
description = "Run tests"
run = "gotestsum"

## <<Stencil::Block(custom)>>
{{ file.Block "custom" }}
## <</Stencil::Block>>
