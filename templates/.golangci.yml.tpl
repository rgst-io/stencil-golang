{{- $license := (stencil.Arg "license") -}}
{{- $licenseObj := (dict "Name" $license) -}}
# yaml-language-server: $schema=https://json.schemastore.org/golangci-lint

version: "2"

# Linter settings
linters:
  settings:
    errcheck:
      check-blank: true
    gocyclo:
      min-complexity: 25
    gocritic:
      enabled-tags:
        - diagnostic
        - experimental
        - opinionated
        - performance
        - style
    goheader:
      template: |-
      {{- if not (eq $license "Proprietary") }}
        Copyright (C) {{ "{{ YEAR }}" }} {{ .Config.Name }} contributors
      {{- else }}
        Copyright (C) {{ "{{ YEAR }}" }} {{ stencil.Arg "copyrightHolder" }}. All rights reserved.
      {{- end }}
{{ stencil.Include (list "code-snippets" "copyright" $license | join ".") $licenseObj | indent 8 }}
      {{- if not (eq $license "Proprietary") }}

        SPDX-License-Identifier: {{ $license }}
      {{- end }}
    lll:
      line-length: 140

  # Inverted configuration with enable-all and disable is not scalable
  # during updates of golangci-lint.
  default: none
  enable:
    - bodyclose
    - dogsled
    - errcheck
    - errorlint
    - exhaustive
    - copyloopvar
    - gochecknoinits
    - gocritic
    - gocyclo
    - goheader
    - gosec
    - govet
    - ineffassign
    - lll
    - misspell
    - nakedret
    - staticcheck
    - revive
    - unconvert
    - unparam
    - unused
    - whitespace

  # Excluding configuration per-path, per-linter, per-text and per-source
  exclusions:
    rules:
      # We allow error shadowing
      - path: '(.+)\.go$'
        text: 'declaration of "err" shadows declaration at'
      # Overly disruptive rule
      - path: '(.+)\.go$'
        text: 'var-naming: avoid package names that conflict with Go standard library package names'
      # Exclude some linters from running on tests files.
      - path: _test\.go
        linters:
          - errcheck
          - funlen
          - gochecknoglobals # Globals in test files are tolerated.
          - gocyclo
          - goheader # Don't require license headers in test files.
          - gosec

# formatter settings
formatters:
  enable:
    - gofmt
    - goimports
