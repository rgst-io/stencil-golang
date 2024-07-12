# yaml-language-server: $schema=https://goreleaser.com/static/schema.json
{{- $org := stencil.Arg "org" }}
version: 2
project_name: {{ .Config.Name }}
before:
  hooks:
    - go mod tidy
report_sizes: true
metadata:
  mod_timestamp: "{{ "{{" }} .CommitTimestamp {{ "}}" }}"
builds:
  - main: ./cmd/{{ "{{ .ProjectName }}" }}
    flags:
      - -trimpath
    ldflags:
      - -s
      - -w
      ## <<Stencil::Block(ldflags)>>
{{ file.Block "ldflags" }}
      ## <</Stencil::Block>>
    env:
      - CGO_ENABLED=0
    goarch:
      - amd64
      - arm64
      ## <<Stencil::Block(extraArch)>>
{{ file.Block "extraArch" }}
      ## <</Stencil::Block>>
    goos:
      - linux
      - darwin
      ## <<Stencil::Block(extraOS)>>
{{ file.Block "extraOS" }}
      ## <</Stencil::Block>>
    ignore:
      - goos: windows
        goarch: arm
    mod_timestamp: "{{ "{{" }} .CommitTimestamp {{ "}}" }}"
{{- if stencil.Exists "Dockerfile" }}
dockers:
  # amd64
  - use: buildx
    build_flag_templates:
      - --platform=linux/amd64
      - --label=org.opencontainers.image.title={{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.description={{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.url=https://github.com/{{ $org }}/{{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.source=https://github.com/{{ $org }}/{{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.version={{ "{{ .Version }}" }}
      - --label=org.opencontainers.image.created={{ "{{ time \"2006-01-02T15:04:05Z07:00\" }}" }}
      - --label=org.opencontainers.image.revision={{ "{{ .FullCommit }}" }}
      - --label=org.opencontainers.image.licenses={{ stencil.Arg "license" }}
    image_templates:
      - "ghcr.io/{{ $org }}/{{ "{{ .ProjectName }}" }}:{{ "{{ .Version }}" }}-amd64"
  # arm64
  - use: buildx
    goos: linux
    goarch: arm64
    build_flag_templates:
      - --platform=linux/arm64
      - --label=org.opencontainers.image.title={{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.description={{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.url=https://github.com/{{ $org }}/{{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.source=https://github.com/{{ $org }}/{{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.version={{ "{{ .Version }}" }}
      - --label=org.opencontainers.image.created={{ "{{ time \"2006-01-02T15:04:05Z07:00\" }}" }}
      - --label=org.opencontainers.image.revision={{ "{{ .FullCommit }}" }}
      - --label=org.opencontainers.image.licenses={{ stencil.Arg "license" }}
    image_templates:
      - "ghcr.io/{{ $org }}/{{ "{{ .ProjectName }}" }}:{{ "{{ .Version }}" }}-arm64"
docker_manifests:
  - name_template: "ghcr.io/{{ $org }}/{{ "{{ .ProjectName }}" }}:{{ "{{ .Version }}" }}"
    image_templates:
      - "ghcr.io/{{ $org }}/{{ "{{ .ProjectName }}" }}:{{ "{{ .Version }}" }}-arm64"
      - "ghcr.io/{{ $org }}/{{ "{{ .ProjectName }}" }}:{{ "{{ .Version }}" }}-amd64"
{{- end }}
checksum:
  name_template: "checksums.txt"
snapshot:
  name_template: "{{ "{{ incpatch .Version }}" }}-next"
changelog:
  use: git
release:
  prerelease: "auto"
  footer: |-
    **Full Changelog**: https://github.com/{{ $org }}/{{ .Config.Name }}/compare/{{ "{{ .PreviousTag }}" }}...{{ "{{ .Tag }}" }}

## <<Stencil::Block(extraReleaseOpts)>>
{{ file.Block "extraReleaseOpts" }}
## <</Stencil::Block>>