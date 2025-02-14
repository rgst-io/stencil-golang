# yaml-language-server: $schema=https://goreleaser.com/static/schema.json
{{- $org := stencil.Arg "org" }}
version: 2
project_name: {{ .Config.Name }}
report_sizes: true
metadata:
  mod_timestamp: "{{ "{{" }} .CommitTimestamp {{ "}}" }}"
builds:
{{- if stencil.Arg "library" }}
  - skip: true
{{- else }}
{{- range $cmd := (stencil.Arg "commands" | default (list .Config.Name)) }}
  - main: ./cmd/{{ $cmd }}
    flags:
      - -trimpath
    ldflags:
      - -s
      - -w
      {{- $ldflagsBlockName := printf "%s%s" $cmd (title "ldflags") }}
      ## <<Stencil::Block({{ $ldflagsBlockName }})>>
{{ file.Block $ldflagsBlockName }}
      ## <</Stencil::Block>>
    env:
      - CGO_ENABLED=0
    goarch:
      - amd64
      - arm64
      {{- $extraArchBlockName := printf "%s%s" $cmd (title "extraArch") }}
      ## <<Stencil::Block({{ $extraArchBlockName }})>>
{{ file.Block $extraArchBlockName }}
      ## <</Stencil::Block>>
    goos:
      - linux
      - darwin
      - windows
      {{- $extraOSBlockName := printf "%s%s" $cmd (title "extraOS") }}
      ## <<Stencil::Block({{ $extraOSBlockName }})>>
{{ file.Block $extraOSBlockName }}
      ## <</Stencil::Block>>
    ignore:
      - goos: windows
        goarch: arm
    mod_timestamp: "{{ "{{" }} .CommitTimestamp {{ "}}" }}"
{{- end }}
{{- end }}
{{- if and (not (stencil.Arg "library")) (stencil.Exists "Dockerfile") }}
dockers:
  # amd64
  - use: buildx
    build_flag_templates:
      - --platform=linux/amd64
      - --label=org.opencontainers.image.title={{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.description={{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.url=https://{{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.source=https://{{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ "{{ .ProjectName }}" }}
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
      - --label=org.opencontainers.image.url=https://{{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ "{{ .ProjectName }}" }}
      - --label=org.opencontainers.image.source=https://{{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ "{{ .ProjectName }}" }}
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
  version_template: "{{ "{{ incpatch .Version }}" }}-next"
changelog:
  use: git
release:
  prerelease: "auto"
  footer: |-
    **Full Changelog**: https://{{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ .Config.Name }}/compare/{{ "{{ .PreviousTag }}" }}...{{ "{{ .Tag }}" }}

## <<Stencil::Block(extraReleaseOpts)>>
{{ file.Block "extraReleaseOpts" }}
## <</Stencil::Block>>
