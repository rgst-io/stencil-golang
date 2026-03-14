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
    id: {{ $cmd }}
    binary: {{ $cmd }}
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
dockers_v2:
  - images:
    ## <<Stencil::Block(extraReleaseOpts)>>
    {{- $block := file.Block "extraReleaseOpts" }}
    {{- if $block }}
{{ $block }}
    {{- else }}
    {{- if (eq (stencil.Arg "vcs") "forgejo") }}
    - {{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ "{{ .ProjectName }}" }}
    {{- end }}
    - ghcr.io/{{ $org }}/{{ "{{ .ProjectName }}" }}
    {{- end }}
    ## <</Stencil::Block>>
    labels:
      "org.opencontainers.image.title": {{ "{{ .ProjectName }}" | quote }}
      "org.opencontainers.image.description": {{ "{{ .ProjectName }}" | quote }}
      "org.opencontainers.image.source": {{ "{{ .GitURL }}" | quote }}
      "org.opencontainers.image.version": {{ "{{ .Version }}" | quote }}
      "org.opencontainers.image.created": {{ "{{ .Date }}" | quote }}
      "org.opencontainers.image.revision": {{ "{{ .FullCommit }}" | quote }}
      "org.opencontainers.image.licenses": {{ stencil.Arg "license" | quote }}
    platforms:
    - linux/amd64
    - linux/arm64
{{- end }}
checksum:
  name_template: "checksums.txt"
snapshot:
  version_template: "{{ "{{ incpatch .Version }}" }}-next"
changelog:
  use: git
release:
  {{- if (eq (stencil.Arg "vcs") "forgejo") }}
  gitea:
    owner: {{ $org }}
    name: {{ .Config.Name }}
  {{- end }}

  prerelease: "auto"
  footer: |-
    **Full Changelog**: https://{{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ .Config.Name }}/compare/{{ "{{ .PreviousTag }}" }}...{{ "{{ .Tag }}" }}

{{- if (eq (stencil.Arg "vcs") "forgejo") }}

gitea_urls:
  api: https://{{ stencil.Arg "vcs_host" }}/api/v1
  download: https://{{ stencil.Arg "vcs_host" }}
{{- end }}

## <<Stencil::Block(extraReleaseOpts)>>
{{ file.Block "extraReleaseOpts" }}
## <</Stencil::Block>>
