# yaml-language-server: $schema=https://goreleaser.com/static/schema.json
# vim: set ts=2 sw=2 tw=0 fo=cnqoj
{{- $org := stencil.Arg "org" }}
project_name: {{ .Config.Name }}
before:
  hooks:
    - go mod download
builds:
  - main: ./cmd/{{ "{{ .ProjectName }}" }}
    flags:
      - -trimpath
    ldflags:
      - -s
      - -w
    env:
      - CGO_ENABLED=0
    goarch:
      - amd64
      - arm64
    goos:
      - linux
      - darwin
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
archives:
  - format: tar.xz
checksum:
  name_template: "checksums.txt"
snapshot:
  name_template: "{{ "{{ incpatch .Version }}" }}-next"
changelog:
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"