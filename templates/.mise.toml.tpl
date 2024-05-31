{{- /* TODO(jaredallard): Don't put this inside of this file */}}
{{- define "defaultVers" }}
# renovate: datasource=golang-version depName=golang
- golang: "1.22"
# renovate: datasource=github-releases depName=shfm packageName=mvdan/sh
- shfmt: "3"
# renovate: datasource=github-releases depName=golangci-lint packageName=golangci/golangci-lint
- golangci-lint: "1.59"
- goreleaser: "latest"
# renovate: datasource=gomod depName=gotestsum packageName=gotest.tools/gotestsum
- "go:gotest.tools/gotestsum": "v1.11.0"
- "go:golang.org/x/tools/cmd/goimports": "latest"
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

[tasks.test]
description = "Run tests"
run = "gotestsum"

[tasks.lint]
description = "Run linters"
run = "golangci-lint run"

[tasks.fmt]
alias = "format"
description = "Format code"
run = [
  "go mod tidy",
  "gofmt -s -w .",
  "goimports -w .",
  "shfmt -w -i 2 -ci -sr .",
]

## <<Stencil::Block(custom)>>
{{ file.Block "custom" }}
## <</Stencil::Block>>